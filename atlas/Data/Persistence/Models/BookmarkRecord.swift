import Foundation
import SwiftData

/// The documentation entry is stored as an encoded snapshot so bookmarks remain readable offline
/// and survive catalogue updates untouched.
@Model
final class BookmarkRecord {
    /// `DocumentationID.storageKey` of the bookmarked page.
    @Attribute(.unique) var key: String
    var title: String
    var createdAt: Date
    /// Entry in the stored format (`EntryPayloadCoder`).
    var entryPayload: Data

    init(key: String, title: String, createdAt: Date, entryPayload: Data) {
        self.key = key
        self.title = title
        self.createdAt = createdAt
        self.entryPayload = entryPayload
    }
}
