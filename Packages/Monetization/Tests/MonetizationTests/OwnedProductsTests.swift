@testable import Monetization
import Testing

struct OwnedProductsTests {
    @Test func `deduplicates product identifiers`() {
        let owned = OwnedProducts.active(from: ["premium.yearly", "premium.yearly", "coins.pack"])
        #expect(owned == ["premium.yearly", "coins.pack"])
    }

    @Test func `empty when nothing is owned`() {
        #expect(OwnedProducts.active(from: []).isEmpty)
    }
}
