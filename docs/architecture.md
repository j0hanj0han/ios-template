# Architecture

## Vue d'ensemble

```
            App  (point d'entrée + composition)
          /  |  \
FeatureHome  |  Monetization
     |   \   |   /
     |  DesignSystem   Core
     \______________/
```

| Module | Rôle | Dépend de |
|---|---|---|
| `App/` | `@main`, crée les modèles et services, les injecte via `.environment()` | tout |
| `Core` | modèles partagés (`EntitlementStore`) et protocoles de services (`PurchaseService`) | rien |
| `DesignSystem` | tokens (`Spacing`, `Radius`), composants, wrapper Liquid Glass | rien |
| `Monetization` | implémentation StoreKit 2 de `PurchaseService` | `Core` |
| `Feature*` | un écran ou un parcours | `Core`, `DesignSystem` |

Règles :
- une Feature ne dépend **jamais** d'une autre Feature ni de `Monetization` ;
- seule `App` connaît les implémentations concrètes ;
- chaque module est un Swift Package local (`Packages/<Nom>/Package.swift`), référencé dans `project.yml`.

## Pattern MV

Pas de ViewModel par défaut. La vue lit directement les modèles `@Observable` injectés :

```swift
// App
HomeView()
    .environment(entitlements)

// Feature
struct HomeView: View {
    @Environment(EntitlementStore.self) private var entitlements
    var body: some View {
        if entitlements.isPremium { ... }
    }
}
```

SwiftUI ne réévalue `body` que si une propriété lue pendant le rendu change. C'est le rôle d'Observation.

### Quand ajouter un `@Observable` d'écran

Seulement si l'écran a de la **logique async** (chargement, pagination) ou de la **validation** (formulaire). Dans ce cas :

```swift
@MainActor @Observable
final class SignUpForm {
    var email = ""
    var isValid: Bool { email.contains("@") }
}

struct SignUpView: View {
    @State private var form = SignUpForm()   // la vue possède son état d'écran
    ...
}
```

### Logique testable

La logique non triviale sort de la vue dans un type pur (voir `AccessStatus` dans `FeatureHome`) et se teste avec Swift Testing, sans UI.

## Services

- Le protocole est déclaré dans `Core` (`PurchaseService`) et l'implémentation vit dans son module (`Monetization`).
- Un service **écrit** dans un modèle observable (`EntitlementStore`) et les vues **lisent** ce modèle.
- Toute l'UI et l'état partagé sont `@MainActor` (strict concurrency complet).

## Liquid Glass

- Les composants système (`NavigationStack`, `TabView`, `.toolbar`, sheets) ont déjà le verre. Ne pas leur mettre de fond.
- Effets custom uniquement via `DesignSystem` :
  - `.floatingGlass()` / `.floatingGlass(in:)` pour un contrôle flottant ;
  - `GlassGroup { ... }` pour regrouper plusieurs éléments en verre (`GlassEffectContainer`).
- Ne pas poser de verre sur du verre.
- Tester avec Réglages › Accessibilité › Affichage et taille du texte › **Réduire la transparence**.

## Ajouter une Feature

1. Copier `Packages/FeatureHome` vers `Packages/FeatureX` et renommer dans son `Package.swift`
2. L'ajouter à `packages:` et aux `dependencies:` de la cible dans `project.yml`, et ajouter son test au scheme
3. `xcodegen generate`
4. Écrire son `CLAUDE.md` (rôle, contenu, règles)

## Outillage

| Outil | Version figée dans |
|---|---|
| XcodeGen, SwiftLint, SwiftFormat | `Mintfile` |
| Fastlane | `Gemfile` + `Gemfile.lock` |
| Ruby | `.ruby-version` |

CI : `.github/workflows/ci.yml` n'appelle que les lanes `test`, `beta` et `release`.
