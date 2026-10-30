import Core
import StoreKit

/// Implémentation StoreKit 2 de `PurchaseService`.
/// Elle ne publie rien elle-même : elle écrit dans `EntitlementStore`, que les vues observent.
@MainActor
public final class StoreKitPurchaseService: PurchaseService {
    private let entitlements: EntitlementStore

    public init(entitlements: EntitlementStore) {
        self.entitlements = entitlements
    }

    public func start() async {
        await refreshEntitlements()
        for await update in Transaction.updates {
            if let transaction = try? update.payloadValue {
                await transaction.finish()
            }
            await refreshEntitlements()
        }
    }

    public func purchase(productID: String) async throws -> PurchaseOutcome {
        guard let product = try await Product.products(for: [productID]).first else {
            throw PurchaseError.productNotFound(productID)
        }
        switch try await product.purchase() {
        case let .success(verification):
            let transaction = try verification.payloadValue
            await transaction.finish()
            await refreshEntitlements()
            return .purchased
        case .pending:
            return .pending
        case .userCancelled:
            return .cancelled
        @unknown default:
            return .cancelled
        }
    }

    public func restorePurchases() async throws {
        try await AppStore.sync()
        await refreshEntitlements()
    }

    private func refreshEntitlements() async {
        var owned: [String] = []
        for await result in Transaction.currentEntitlements {
            if let transaction = try? result.payloadValue {
                owned.append(transaction.productID)
            }
        }
        entitlements.update(ownedProductIDs: OwnedProducts.active(from: owned))
    }
}

public enum PurchaseError: Error, Equatable {
    case productNotFound(String)
}
