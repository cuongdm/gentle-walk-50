import Foundation
import RevenueCat
import GentleWalkCore

/// The RevenueCat public SDK key from build settings (Config/Local.xcconfig `REVENUECAT_PUBLIC_KEY` →
/// Info.plist `RevenueCatPublicKey`), never typed in code (owner 09/10/2026).
enum RevenueCatKey {
    static let infoPlistKey = "RevenueCatPublicKey"

    /// The key, or nil when it is empty, unexpanded, the example placeholder or not a public key.
    /// App Store keys start with "appl_"; Debug also takes RevenueCat Test Store keys ("test_").
    static func validated(_ raw: String?) -> String? {
        guard let key = raw?.trimmingCharacters(in: .whitespacesAndNewlines), !key.isEmpty,
              !key.contains("XXXX"), !key.contains("$(") else { return nil }
        #if DEBUG
        let prefixes = ["appl_", "test_"]
        #else
        let prefixes = ["appl_"]
        #endif
        return prefixes.contains(where: key.hasPrefix) ? key : nil
    }

    static func fromBundle(_ bundle: Bundle = .main) -> String? {
        validated(bundle.object(forInfoDictionaryKey: infoPlistKey) as? String)
    }
}

/// `PurchaseBackend` on the RevenueCat SDK; the only file that imports it. Anonymous app user ID (no
/// accounts, no `logIn`), StoreKit 2, no device identifiers collected for ad networks.
@MainActor final class RevenueCatBackend: PurchaseBackend {
    /// Entitlement and offering set up in the RevenueCat project (docs/release/1.0/revenuecat-setup.md).
    nonisolated static let entitlementID = "pro"
    nonisolated static let offeringID = "default"

    private let purchases: Purchases
    /// What a purchase needs, from the last `offers()`: the package when the offering has one (so
    /// RevenueCat can attribute offerings and experiments), the bare product otherwise.
    private var packages: [String: Package] = [:]
    private var products: [String: StoreProduct] = [:]

    private init(purchases: Purchases) { self.purchases = purchases }

    /// Configures RevenueCat once and returns the backend; nil (the app runs free, with no store) when
    /// the build has no key, and always under unit tests so they never reach the network.
    static func configured(bundle: Bundle = .main) -> RevenueCatBackend? {
        #if DEBUG
        if ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil { return nil }
        #endif
        guard let key = RevenueCatKey.fromBundle(bundle) else { return nil }
        if !Purchases.isConfigured {
            #if DEBUG
            Purchases.logLevel = .info
            #else
            Purchases.logLevel = .error
            #endif
            Purchases.configure(with: Configuration.Builder(withAPIKey: key)
                .with(storeKitVersion: .storeKit2)
                // No attribution networks: never send IDFA/IDFV/IP for them.
                .with(automaticDeviceIdentifierCollectionEnabled: false)
                .build())
        }
        return RevenueCatBackend(purchases: Purchases.shared)
    }

    // MARK: PurchaseBackend

    func offers(refresh: Bool) async throws -> [StoreOffer] {
        packages = [:]
        products = [:]
        var found: [PlanKind: StoreProduct] = [:]
        // The offering first, so a price test set up in RevenueCat reaches the paywall without an update.
        // After a plan the store can't sell, fetched again rather than from the cache (rate-limited by
        // RevenueCat, which then falls back to the cache).
        let offerings: Offerings?
        if refresh {
            offerings = try? await purchases.syncAttributesAndOfferingsIfNeeded()
        } else {
            offerings = try? await purchases.offerings()
        }
        if let offerings, let offering = offerings.current ?? offerings.offering(identifier: Self.offeringID) {
            for (kind, package) in [(PlanKind.yearly, offering.annual), (.monthly, offering.monthly), (.lifetime, offering.lifetime)] {
                guard let package else { continue }
                found[kind] = package.storeProduct
                packages[package.storeProduct.productIdentifier] = package
            }
        }
        // No offering yet (project not set up, or it failed): the three App Store products directly.
        if found.isEmpty {
            for product in await purchases.products(ProductID.all) {
                guard let kind = PlanKind(productID: product.productIdentifier) else { continue }
                found[kind] = product
            }
        }
        guard !found.isEmpty else { throw StoreError.productUnavailable }
        for product in found.values { products[product.productIdentifier] = product }
        return found.sorted { $0.key < $1.key }.map { kind, product in
            StoreOffer(id: product.productIdentifier, kind: kind, displayPrice: product.localizedPriceString,
                       price: product.price, currencyCode: product.currencyCode,
                       freeTrialDays: kind == .lifetime ? nil : Self.freeTrialDays(product.introductoryDiscount))
        }
    }

    func customer() async throws -> CustomerSnapshot {
        Self.snapshot(try await purchases.customerInfo())
    }

    func customerUpdates() -> AsyncStream<CustomerSnapshot> {
        let source = purchases.customerInfoStream
        return AsyncStream { continuation in
            let task = Task {
                for await info in source { continuation.yield(Self.snapshot(info)) }
                continuation.finish()
            }
            continuation.onTermination = { _ in task.cancel() }
        }
    }

    func purchase(_ productID: String) async throws -> BackendPurchase {
        do {
            let result: PurchaseResultData
            if let package = packages[productID] {
                result = try await purchases.purchase(package: package)
            } else if let product = products[productID] {
                result = try await purchases.purchase(product: product)
            } else {
                throw StoreError.productUnavailable
            }
            return result.userCancelled ? .cancelled : .purchased(Self.snapshot(result.customerInfo))
        } catch {
            switch Self.code(of: error) {
            case .paymentPendingError: return .pending
            case .purchaseCancelledError: return .cancelled
            default: throw Self.failure(error)
            }
        }
    }

    func restore() async throws -> CustomerSnapshot {
        Self.snapshot(try await purchases.restorePurchases())
    }

    func introEligibility(for productID: String) async -> GentleWalkCore.IntroEligibility {
        guard let product = products[productID] else { return .unknown }
        switch await purchases.checkTrialOrIntroDiscountEligibility(product: product) {
        case .eligible: return .eligible
        case .ineligible: return .ineligible
        case .noIntroOfferExists: return .noOffer
        case .unknown: return .unknown
        @unknown default: return .unknown
        }
    }

    // MARK: Mapping (pure)

    /// The parts of `CustomerInfo` the core rules read.
    nonisolated static func snapshot(_ info: CustomerInfo) -> CustomerSnapshot {
        let pro = info.entitlements.all[entitlementID].map { entitlement in
            ProAccess(productID: entitlement.productIdentifier, isActive: entitlement.isActive,
                      isTrial: entitlement.periodType == .trial, expirationDate: entitlement.expirationDate,
                      willRenew: entitlement.willRenew)
        }
        let subscriptions = info.subscriptionsByProductIdentifier.values
            .map { SubscriptionState(productID: $0.productIdentifier, isActive: $0.isActive, willRenew: $0.willRenew,
                                     expiresDate: $0.expiresDate) }
            .sorted { $0.productID < $1.productID }
        return CustomerSnapshot(pro: pro, subscriptions: subscriptions, purchasedProductIDs: info.allPurchasedProductIdentifiers)
    }

    /// Days of a free-trial introductory offer; nil for a paid intro offer or none (review I-1).
    nonisolated static func freeTrialDays(_ discount: StoreProductDiscount?) -> Int? {
        guard let discount, discount.paymentMode == .freeTrial else { return nil }
        let period = discount.subscriptionPeriod
        let unit: TrialOffer.Unit = switch period.unit {
        case .day: .day
        case .week: .week
        case .month: .month
        case .year: .year
        @unknown default: .day
        }
        return TrialOffer.days(value: period.value * max(1, discount.numberOfPeriods), unit: unit)
    }

    /// RevenueCat's error code behind a thrown error (it throws bridged `NSError`s).
    nonisolated static func code(of error: Error) -> ErrorCode? {
        if let code = error as? ErrorCode { return code }
        let error = error as NSError
        return error.domain == ErrorCode.errorDomain ? ErrorCode(rawValue: error.code) : nil
    }

    /// The domain of RevenueCat's errors, so tests can build one without importing the SDK.
    nonisolated static var errorDomain: String { ErrorCode.errorDomain }

    /// What a failed purchase means for the paywall, with RevenueCat's code and the store error under it
    /// for the log (e.g. "RevenueCat 5 PRODUCT_NOT_AVAILABLE_FOR_PURCHASE, root StoreKit.StoreKitError 3").
    /// Only codes and domains: never the error's message, which can carry account details.
    nonisolated static func failure(_ error: Error) -> PurchaseFailure {
        if let failure = error as? PurchaseFailure { return failure }
        if case StoreError.productUnavailable? = error as? StoreError {
            return PurchaseFailure(reason: .planUnavailable, code: "product not loaded")
        }
        let info = (error as NSError).userInfo
        guard let code = code(of: error) else {
            let error = error as NSError
            return PurchaseFailure(reason: .other, code: "\(error.domain) \(error.code)")
        }
        let reason: PurchaseFailure.Reason = switch code {
        case .productNotAvailableForPurchaseError: .planUnavailable
        case .networkError, .offlineConnectionError: .network
        default: .other
        }
        var text = "RevenueCat \(code.rawValue)"
        if let readable = info["readable_error_code"] as? String { text += " \(readable)" }
        if let root = info["rc_root_error"] as? [String: Any], let domain = root["domain"] as? String,
           let rootCode = root["code"] as? Int {
            text += ", root \(domain) \(rootCode)"
        }
        return PurchaseFailure(reason: reason, code: text)
    }
}
