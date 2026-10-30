# FeatureHome

Écran d'accueil de l'app.

## Contenu
- `HomeView` : la seule vue publique, point d'entrée de la feature
- `AccessStatus` : état dérivé du modèle (logique pure, testée dans `FeatureHomeTests`)

## Règles
- Dépend uniquement de `Core` et `DesignSystem`, jamais d'une autre Feature ni de `Monetization`
- Pattern MV : lire `EntitlementStore` via `@Environment`, pas de ViewModel
- Ajouter un `@Observable` d'écran seulement si de la logique async ou de la validation apparaît
- Effets Liquid Glass custom : uniquement via `DesignSystem` (`floatingGlass`, `GlassGroup`)
- Toute logique non triviale sort de la vue dans un type pur, testé avec Swift Testing
