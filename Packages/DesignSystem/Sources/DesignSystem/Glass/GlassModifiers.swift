import SwiftUI

// Point d'entrée unique pour Liquid Glass custom.
// Les Features n'appellent jamais `glassEffect` directement : elles passent par ces API.

public extension View {
    /// Verre pour un contrôle flottant custom (bouton flottant, pastille…).
    /// À ne pas utiliser sur des barres système, qui ont déjà leur verre.
    func floatingGlass(in shape: some Shape, interactive: Bool = true) -> some View {
        glassEffect(interactive ? .regular.interactive() : .regular, in: shape)
    }

    /// Variante en capsule, la forme la plus courante.
    func floatingGlass(interactive: Bool = true) -> some View {
        floatingGlass(in: Capsule(), interactive: interactive)
    }
}

/// Regroupe plusieurs éléments en verre pour qu'ils se rendent et fusionnent ensemble.
public struct GlassGroup<Content: View>: View {
    private let spacing: CGFloat
    private let content: Content

    public init(spacing: CGFloat = Spacing.medium, @ViewBuilder content: () -> Content) {
        self.spacing = spacing
        self.content = content()
    }

    public var body: some View {
        GlassEffectContainer(spacing: spacing) {
            content
        }
    }
}
