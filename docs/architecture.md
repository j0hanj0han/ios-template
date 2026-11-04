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

### Appeler un service depuis une Feature

Un protocole ne peut pas passer par `.environment(_:)` (réservé aux classes `@Observable`) : `Core` l'expose donc comme valeur d'environnement, injectée par `App`.

```swift
// App
HomeView()
    .environment(\.purchaseService, purchases)

// Feature : ne connaît que le protocole, jamais StoreKit
struct PaywallView: View {
    @Environment(\.purchaseService) private var purchaseService

    var body: some View {
        Button("Passer Premium") {
            Task { _ = try? await purchaseService?.purchase(productID: "…") }
        }
    }
}
```

La valeur est `nil` dans les previews : la vue s'affiche, le bouton ne fait rien.

## Monétisation

- Produits de test : `Packages/Monetization/StoreKit/Products.storekit`, branché sur l'action Run du scheme. Lancée depuis Xcode, l'app achète sans App Store ni compte sandbox. Chaque app y remplace `com.example.apptemplate.premium.yearly` par ses vrais identifiants, comme dans `App/`.
- Test d'achat automatisé : `AppTests/` (cible `AppTemplateTests`) achète via `SKTestSession` avec ce même fichier. StoreKitTest impose :
  - une **app hôte** : ces tests ne peuvent pas vivre dans le package Monetization ;
  - un **simulateur de la même version que le SDK** : avec Xcode 27.2, le test passe sur iOS 27.2 et échoue toujours sur iOS 26.5 (aucun produit renvoyé). La CI fige Xcode 27.0, aligné sur le seul simulateur iPhone de l'image `xcode-27` (iOS 27.0).
- Quand l'app sert d'hôte aux tests, elle n'appelle pas `purchases.start()` : interroger StoreKit avant que le test installe sa configuration laissait un simulateur neuf sans produits (`productNotFound`).
- Connu : sur un simulateur jamais démarré, le premier achat bloque, puis passe au lancement suivant. Les logs du simulateur (iOS 27.2) montrent pourquoi : faute de compte App Store de test actif, `storekitd` lance une authentification Apple ID, et AuthKit attend une fenêtre de connexion que personne ne remplit (`disableDialogs` ne la couvre pas). Démarrer le simulateur à l'avance n'y change rien. La CI démarre toujours sur un simulateur neuf : le test a donc une limite d'une minute, et la lane `test` relance une fois un test en échec, dans un nouveau process (`number_of_retries` dans le Fastfile). Un vrai bug échoue aux deux passages.
- `App/PrivacyInfo.xcprivacy` : manifeste de confidentialité exigé par l'App Store, vide dans le template. Chaque app y déclare ce qu'elle collecte et ses API à raison déclarée (`UserDefaults`, etc.).

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
