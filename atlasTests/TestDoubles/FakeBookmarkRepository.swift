import Foundation
@testable import atlas

@MainActor
final class FakeBookmarkRepository: BookmarkRepository {
    private var storage: [DocumentationID: Bookmark] = [:]

    func bookmarks() throws -> [Bookmark] {
        storage.values.sorted { $0.createdAt > $1.createdAt }
    }

    func isBookmarked(_ id: DocumentationID) throws -> Bool {
        storage[id] != nil
    }

    func addBookmark(for entry: DocumentationEntry, at date: Date) throws {
        storage[entry.id] = Bookmark(entry: entry, createdAt: date)
    }

    func removeBookmark(_ id: DocumentationID) throws {
        storage[id] = nil
    }
}
