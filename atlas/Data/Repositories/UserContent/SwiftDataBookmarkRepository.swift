import Foundation
import OSLog
import SwiftData

final class SwiftDataBookmarkRepository: BookmarkRepository {
    private static let logger = Logger(subsystem: "atlas", category: "Bookmarks")

    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func bookmarks() throws -> [Bookmark] {
        let descriptor = FetchDescriptor<BookmarkRecord>(sortBy: [SortDescriptor(\.createdAt, order: .reverse)])
        var migrated = false
        let bookmarks = try context.fetch(descriptor).compactMap { record -> Bookmark? in
            do {
                let decoded = try EntryPayloadCoder.decode(record.entryPayload)
                if decoded.needsMigration {
                    record.entryPayload = try EntryPayloadCoder.encode(decoded.entry)
                    migrated = true
                }
                return Bookmark(entry: decoded.entry, createdAt: record.createdAt)
            } catch {
                // Keep the record (a future version may read it) but skip it for now.
                Self.logger.error("Skipping unreadable bookmark \(record.key, privacy: .public): \(error)")
                return nil
            }
        }
        if migrated { try context.save() }
        return bookmarks
    }

    func isBookmarked(_ id: DocumentationID) throws -> Bool {
        try record(for: id) != nil
    }

    func addBookmark(for entry: DocumentationEntry, at date: Date) throws {
        let payload = try EntryPayloadCoder.encode(entry)
        if let existing = try record(for: entry.id) {
            existing.title = entry.title
            existing.entryPayload = payload
        } else {
            context.insert(BookmarkRecord(key: entry.id.storageKey, title: entry.title, createdAt: date, entryPayload: payload))
        }
        try context.save()
    }

    func removeBookmark(_ id: DocumentationID) throws {
        guard let existing = try record(for: id) else { return }
        context.delete(existing)
        try context.save()
    }

    private func record(for id: DocumentationID) throws -> BookmarkRecord? {
        let key = id.storageKey
        var descriptor = FetchDescriptor<BookmarkRecord>(predicate: #Predicate { $0.key == key })
        descriptor.fetchLimit = 1
        return try context.fetch(descriptor).first
    }
}
