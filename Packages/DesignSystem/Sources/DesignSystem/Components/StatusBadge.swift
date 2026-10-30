import SwiftUI

/// Pastille d'état (icône + libellé). Surface pleine, pas de verre : elle se pose sur du contenu.
public struct StatusBadge: View {
    private let title: LocalizedStringKey
    private let systemImage: String
    private let tint: Color

    public init(_ title: LocalizedStringKey, systemImage: String, tint: Color = .accentColor) {
        self.title = title
        self.systemImage = systemImage
        self.tint = tint
    }

    public var body: some View {
        Label(title, systemImage: systemImage)
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(tint)
            .padding(.horizontal, Spacing.medium)
            .padding(.vertical, Spacing.small)
            .background(tint.opacity(0.12), in: Capsule())
    }
}

#Preview {
    VStack(spacing: Spacing.medium) {
        StatusBadge("Premium", systemImage: "crown.fill", tint: .orange)
        StatusBadge("Gratuit", systemImage: "person.fill", tint: .secondary)
    }
}
