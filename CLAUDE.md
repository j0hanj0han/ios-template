# CLAUDE.md — ios-template

## Rôle de ce repo
Template GitHub pour des apps iOS monétisées.
Si le squelette n'existe pas encore : génère-le d'après l'arborescence ci-dessous, puis vérifie qu'il compile.

## Stack (versions explicites, ne pas deviner)
- Xcode 27, Swift 6.4, strict concurrency complet
- Cible minimale : **iOS 26**
- SwiftUI, Observation (`@Observable`), Swift Testing
- XcodeGen (`project.yml`) : ne jamais versionner le `.xcodeproj`
- Versions des outils figées : `Mintfile` (XcodeGen, SwiftLint, SwiftFormat) et `Gemfile.lock` (Fastlane)
- Ne jamais monter une version de toi-même. Context7 sert seulement à signaler les écarts.

## Arborescence
```
App/            point d'entrée + composition, rien d'autre
AppTests/       tests qui ont besoin de l'app hôte (achats StoreKitTest)
Packages/
  Core/         modèles, protocoles de services
  DesignSystem/ tokens, composants, wrapper Liquid Glass
  Monetization/ StoreKit
  FeatureHome/  1 vue + 1 test + CLAUDE.md
docs/architecture.md
fastlane/  .github/workflows/  .mcp.json
```

## Architecture
- Modules = Swift Packages locaux. Une Feature dépend de Core et DesignSystem, jamais d'une autre Feature.
- UI en pattern **MV** : pas de ViewModel par défaut, la vue utilise les modèles et les services injectés via `.environment()`.
- Un `@Observable` par écran seulement s'il y a de la logique async ou de la validation.
- Détails et exemples : `docs/architecture.md`. Règles d'un module : `Packages/<Feature>/CLAUDE.md`.

## Règles SwiftUI
- Pas d'`AnyView` (bloqué aussi par SwiftLint)
- Des `body` courts : extraire des sous-vues dès que ça s'allonge

## Liquid Glass (iOS 26)
- Utiliser les composants système (`NavigationStack`, `TabView`, `.toolbar`, sheets) : ils adoptent Liquid Glass tout seuls
- Ne pas mettre de fond custom sur les barres d'outils ou d'onglets, ça casse l'effet
- `glassEffect` et `.buttonStyle(.glass)` seulement pour les contrôles flottants custom
- Regrouper plusieurs éléments en verre dans un `GlassEffectContainer`
- Pas de verre posé sur du verre
- Tout effet custom passe par le wrapper de `DesignSystem`, jamais directement dans une Feature
- Vérifier la lisibilité avec « Réduire la transparence » activé

## Commandes
- Setup : `mint bootstrap && xcodegen generate`
- Tests : `bundle exec fastlane test`
- Build, tests et simulateur : passer par MobileBuildMCP (ex-XcodeBuildMCP, version figée dans `.mcp.json`) en priorité

## Boucle de dev
1. Lire `PLAN.md`, section « État courant » (créé pour chaque app par `/new-app` ; absent dans le template lui-même)
2. Coder le jalon
3. Build + tests via MobileBuildMCP, lancer dans le simulateur, capture d'écran si c'est de l'UI
4. Corriger jusqu'au vert
5. Mettre à jour « État courant » dans `PLAN.md`, puis commit

## CI
- `.github/workflows/ci.yml` n'appelle que des lanes Fastlane, aucune logique dupliquée dans le YAML
- Lanes : `test` sur chaque PR, `beta` vers TestFlight, `release` vers l'App Store
- Runner macOS, outils installés via `Gemfile.lock` et `Mintfile`
- Signature via match, secrets dans GitHub Secrets uniquement
- La configuration propre à chaque app (App Store Connect, match, secrets) se fait avec la skill `/setup-ci` du plugin `ios-toolkit`, pas ici

## Mode pédagogique (toujours actif)
Johan apprend SwiftUI, avec un background senior Python.
À chaque changement, explique en 2-3 phrases les idiomes Swift/SwiftUI utilisés et pourquoi ce choix, avec un parallèle Python quand ça aide. Pas de cours magistral.

## Definition of done
- Compile sans warning, tests verts
- SwiftLint et SwiftFormat propres
- `PLAN.md` à jour

## Interdits
- Aucun secret, certificat ou clé dans le repo
- `fastlane/` et `.github/` sont créés lors de la génération du squelette ; ensuite, ne pas y toucher sans demande explicite