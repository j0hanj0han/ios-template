@testable import Core
import Testing

@MainActor
struct EntitlementStoreTests {
    @Test func `free by default`() {
        let store = EntitlementStore(premiumProductIDs: ["premium.yearly"])
        #expect(!store.isPremium)
    }

    @Test func `premium once a premium product is owned`() {
        let store = EntitlementStore(premiumProductIDs: ["premium.yearly", "premium.monthly"])
        store.update(ownedProductIDs: ["premium.monthly"])
        #expect(store.isPremium)
    }

    @Test func `non premium products do not unlock premium`() {
        let store = EntitlementStore(premiumProductIDs: ["premium.yearly"])
        store.update(ownedProductIDs: ["coins.pack"])
        #expect(!store.isPremium)
    }
}
