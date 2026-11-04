import Core
import Monetization
import StoreKitTest
import Testing

/// Achats simulés via `Products.storekit`, sans App Store ni compte sandbox.
/// StoreKitTest exige une app hôte et un simulateur de la même version que le SDK :
/// ces tests ne peuvent pas vivre dans le package Monetization.
/// Sur un simulateur jamais démarré, le premier achat bloque, puis passe au lancement suivant :
/// `timeLimit` coupe le blocage au bout d'une minute, et la lane `test` relance le test une fois.
/// `.serialized` : la session StoreKit de test est globale au process.
@MainActor
@Suite(.serialized, .timeLimit(.minutes(1)))
struct StoreKitPurchaseServiceTests {
    private static let premiumID = "com.example.apptemplate.premium.yearly"
    private let session: SKTestSession

    init() throws {
        session = try SKTestSession(configurationFileNamed: "Products")
        session.resetToDefaultState()
        session.clearTransactions()
        session.disableDialogs = true
    }

    @Test func `purchase unlocks premium`() async throws {
        let entitlements = EntitlementStore(premiumProductIDs: [Self.premiumID])
        let service = StoreKitPurchaseService(entitlements: entitlements)

        let outcome = try await service.purchase(productID: Self.premiumID)

        #expect(outcome == .purchased)
        #expect(entitlements.isPremium)
    }

    @Test func `unknown product throws`() async {
        let service = StoreKitPurchaseService(entitlements: EntitlementStore(premiumProductIDs: []))

        await #expect(throws: PurchaseError.productNotFound("inconnu")) {
            try await service.purchase(productID: "inconnu")
        }
    }
}
