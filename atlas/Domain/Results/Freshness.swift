import Foundation

nonisolated enum Freshness: Hashable, Sendable {
    case fresh
    /// Served from the local cache within its validity period.
    case cached(fetchedAt: Date)
    /// Served from the local cache after the source could not be reached.
    case stale(fetchedAt: Date)
}
