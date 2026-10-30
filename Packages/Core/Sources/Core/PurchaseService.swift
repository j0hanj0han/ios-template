/// Résultat d'une tentative d'achat, indépendant de StoreKit.
public enum PurchaseOutcome: Sendable, Equatable {
    case purchased
    case pending
    case cancelled
}

/// Contrat du service d'achat. L'implémentation StoreKit vit dans Monetization.
@MainActor
public protocol PurchaseService: AnyObject {
    /// Écoute les transactions et maintient `EntitlementStore` à jour. Ne rend la main qu'à l'annulation.
    func start() async
    func purchase(productID: String) async throws -> PurchaseOutcome
    func restorePurchases() async throws
}
