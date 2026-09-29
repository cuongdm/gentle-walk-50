import Foundation

/// Product identifiers (App Store Connect and App/GentleWalk.storekit).
public enum ProductID {
    public static let yearly = "com.kmd.gentlewalk.pro.yearly"
    public static let monthly = "com.kmd.gentlewalk.pro.monthly"
    public static let lifetime = "com.kmd.gentlewalk.pro.lifetime"
    public static let subscriptions: Set<String> = [yearly, monthly]
    public static let all: [String] = [yearly, monthly, lifetime]
}

/// The parts of a StoreKit `Transaction` the rules need; the app maps each verified transaction.
public struct TransactionSnapshot: Equatable, Sendable {
    public var productID: String
    public var purchaseDate: Date
    public var expirationDate: Date?
    public var revocationDate: Date?
    /// Introductory offer with the free-trial payment mode.
    public var isFreeTrial: Bool

    public init(productID: String, purchaseDate: Date, expirationDate: Date?, revocationDate: Date?, isFreeTrial: Bool) {
        self.productID = productID; self.purchaseDate = purchaseDate; self.expirationDate = expirationDate
        self.revocationDate = revocationDate; self.isFreeTrial = isFreeTrial
    }
}

/// Entitlement from current transactions (task 2.14). Lifetime wins; revoked or expired never count.
public enum EntitlementRules {
    public static func resolve(_ snapshots: [TransactionSnapshot], now: Date) -> Entitlement {
        let valid = snapshots.filter { $0.revocationDate == nil }
        if valid.contains(where: { $0.productID == ProductID.lifetime }) { return .lifetime }
        let active = valid.filter { snapshot in
            guard ProductID.subscriptions.contains(snapshot.productID), let expires = snapshot.expirationDate else { return false }
            return expires > now
        }
        if active.contains(where: { !$0.isFreeTrial }) { return .subscribed }
        if let trial = active.max(by: { $0.expirationDate! < $1.expirationDate! }), let ends = trial.expirationDate {
            return .trial(ends: ends)
        }
        return .free
    }
}
