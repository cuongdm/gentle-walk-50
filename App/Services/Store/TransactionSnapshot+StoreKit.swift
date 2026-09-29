import StoreKit
import GentleWalkCore

extension TransactionSnapshot {
    /// The parts of a verified StoreKit transaction that `EntitlementRules` needs.
    init(_ transaction: Transaction) {
        let offer = transaction.offer
        self.init(productID: transaction.productID, purchaseDate: transaction.purchaseDate,
                  expirationDate: transaction.expirationDate, revocationDate: transaction.revocationDate,
                  isFreeTrial: offer?.type == .introductory && offer?.paymentMode == .freeTrial)
    }
}
