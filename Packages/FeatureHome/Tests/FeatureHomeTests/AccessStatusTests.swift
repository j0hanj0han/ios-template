@testable import FeatureHome
import Testing

struct AccessStatusTests {
    @Test(arguments: [(false, AccessStatus.free), (true, .premium)])
    func `status follows premium flag`(isPremium: Bool, expected: AccessStatus) {
        #expect(AccessStatus(isPremium: isPremium) == expected)
    }

    @Test func `premium uses the crown symbol`() {
        #expect(AccessStatus.premium.systemImage == "crown.fill")
    }
}
