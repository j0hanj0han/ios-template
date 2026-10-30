/// Logique pure, isolée de StoreKit pour être testable.
enum OwnedProducts {
    /// Dédoublonne les identifiants issus des transactions actives.
    static func active(from productIDs: some Sequence<String>) -> Set<String> {
        Set(productIDs)
    }
}
