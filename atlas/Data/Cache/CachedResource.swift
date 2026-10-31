import Foundation

nonisolated struct CachedResource: Sendable {
    let data: Data
    let validators: CacheValidators
    let fetchedAt: Date
}
