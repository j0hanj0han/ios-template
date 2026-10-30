import Core
import DesignSystem
import SwiftUI

/// Écran d'accueil. Pattern MV : pas de ViewModel, la vue lit directement le modèle injecté.
public struct HomeView: View {
    @Environment(EntitlementStore.self) private var entitlements

    public init() {}

    public var body: some View {
        NavigationStack {
            content
                .navigationTitle("Accueil")
        }
    }

    private var content: some View {
        let status = AccessStatus(isPremium: entitlements.isPremium)
        return ContentUnavailableView {
            Label("Bienvenue", systemImage: "sparkles")
        } description: {
            Text("Remplace cet écran par ta première fonctionnalité.")
        } actions: {
            StatusBadge(status.title, systemImage: status.systemImage, tint: status.tint)
        }
    }
}

/// État d'accès affiché à l'écran, dérivé du modèle. Logique pure, donc testable sans UI.
enum AccessStatus: Equatable {
    case free
    case premium

    init(isPremium: Bool) {
        self = isPremium ? .premium : .free
    }

    var title: LocalizedStringKey {
        switch self {
        case .free: "Gratuit"
        case .premium: "Premium"
        }
    }

    var systemImage: String {
        switch self {
        case .free: "person.fill"
        case .premium: "crown.fill"
        }
    }

    var tint: Color {
        switch self {
        case .free: .secondary
        case .premium: .orange
        }
    }
}

#Preview("Gratuit") {
    HomeView()
        .environment(EntitlementStore(premiumProductIDs: ["premium"]))
}

#Preview("Premium") {
    HomeView()
        .environment(EntitlementStore(premiumProductIDs: ["premium"], ownedProductIDs: ["premium"]))
}
