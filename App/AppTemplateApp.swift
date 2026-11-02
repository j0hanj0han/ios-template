import Core
import FeatureHome
import Monetization
import SwiftUI

@main
struct AppTemplateApp: App {
    @State private var entitlements: EntitlementStore
    @State private var purchases: StoreKitPurchaseService

    init() {
        let entitlements = EntitlementStore(premiumProductIDs: ["com.example.apptemplate.premium.yearly"])
        _entitlements = State(initialValue: entitlements)
        _purchases = State(initialValue: StoreKitPurchaseService(entitlements: entitlements))
    }

    var body: some Scene {
        WindowGroup {
            HomeView()
                .environment(entitlements)
                .environment(\.purchaseService, purchases)
                .task { await purchases.start() }
        }
    }
}
