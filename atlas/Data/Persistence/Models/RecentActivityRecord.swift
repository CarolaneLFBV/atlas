import Foundation
import SwiftData

/// One record per page; reopening updates `lastOpenedAt`.
@Model
final class RecentActivityRecord {
    /// `DocumentationID.storageKey` of the opened page.
    @Attribute(.unique) var key: String
    var lastOpenedAt: Date
    /// Entry in the stored format (`EntryPayloadCoder`).
    var entryPayload: Data

    init(key: String, lastOpenedAt: Date, entryPayload: Data) {
        self.key = key
        self.lastOpenedAt = lastOpenedAt
        self.entryPayload = entryPayload
    }
}
