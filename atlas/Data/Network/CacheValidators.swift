import Foundation

nonisolated struct CacheValidators: Hashable, Sendable {
    var etag: String?
    var lastModified: String?

    var isEmpty: Bool { etag == nil && lastModified == nil }
}
