import SwiftUI

public extension EnvironmentValues {
    /// Service d'achat injecté par `App`. `nil` dans les previews et tant que rien n'est injecté.
    ///
    /// Une Feature l'appelle sans connaître StoreKit :
    /// `try await purchaseService?.purchase(productID: id)`.
    @Entry var purchaseService: any PurchaseService?
}
