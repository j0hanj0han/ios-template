import Observation

/// Droits d'accès de l'utilisateur, partagés par toute l'app.
///
/// Les vues le lisent via `@Environment(EntitlementStore.self)` ;
/// seul le service d'achat (module Monetization) le met à jour.
@MainActor
@Observable
public final class EntitlementStore {
    public private(set) var ownedProductIDs: Set<String>
    public let premiumProductIDs: Set<String>

    public var isPremium: Bool {
        !ownedProductIDs.isDisjoint(with: premiumProductIDs)
    }

    public init(premiumProductIDs: Set<String>, ownedProductIDs: Set<String> = []) {
        self.premiumProductIDs = premiumProductIDs
        self.ownedProductIDs = ownedProductIDs
    }

    public func update(ownedProductIDs: Set<String>) {
        self.ownedProductIDs = ownedProductIDs
    }
}
