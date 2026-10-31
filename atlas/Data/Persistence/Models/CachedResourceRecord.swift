import Foundation
import SwiftData

/// Kept separate from user content so cache maintenance can never affect bookmarks or snippets.
@Model
final class CachedResourceRecord {
    /// Source-qualified resource key, e.g. `apple:/documentation/swiftui`.
    @Attribute(.unique) var key: String
    var sourceID: String
    @Attribute(.externalStorage) var payload: Data
    var etag: String?
    var lastModified: String?
    var fetchedAt: Date

    init(key: String, sourceID: String, payload: Data, etag: String?, lastModified: String?, fetchedAt: Date) {
        self.key = key
        self.sourceID = sourceID
        self.payload = payload
        self.etag = etag
        self.lastModified = lastModified
        self.fetchedAt = fetchedAt
    }
}
