import Foundation
import SwiftData
import Testing
@testable import atlas

@MainActor
@Suite("SwiftDataBookmarkRepository")
struct SwiftDataBookmarkRepositoryTests {
    let container: ModelContainer
    let repository: SwiftDataBookmarkRepository

    init() throws {
        container = try PersistenceStore.makeContainer(inMemory: true)
        repository = SwiftDataBookmarkRepository(context: container.mainContext)
    }

    @Test("Re-bookmarking an entry keeps a single record and refreshes its snapshot")
    func upsert() throws {
        let original = Fixture.entry("View", path: "/documentation/swiftui/view")
        let renamed = DocumentationEntry(id: original.id, title: "View (renamed)", kind: original.kind, frameworkName: "SwiftUI")

        try repository.addBookmark(for: original, at: Date(timeIntervalSince1970: 1))
        try repository.addBookmark(for: renamed, at: Date(timeIntervalSince1970: 2))

        let bookmarks = try repository.bookmarks()
        #expect(bookmarks.count == 1)
        #expect(bookmarks.first?.entry.title == "View (renamed)")
        #expect(bookmarks.first?.createdAt == Date(timeIntervalSince1970: 1))
    }

    @Test("Bookmarks are listed newest first and can be removed")
    func orderingAndRemoval() throws {
        let older = Fixture.entry("List")
        let newer = Fixture.entry("Form")
        try repository.addBookmark(for: older, at: Date(timeIntervalSince1970: 1))
        try repository.addBookmark(for: newer, at: Date(timeIntervalSince1970: 2))

        #expect(try repository.bookmarks().map(\.entry.title) == ["Form", "List"])

        try repository.removeBookmark(older.id)
        #expect(try repository.isBookmarked(older.id) == false)
        #expect(try repository.isBookmarked(newer.id))
    }

    @Test("Removing an entry that isn't bookmarked is a no-op")
    func removeMissing() throws {
        try repository.removeBookmark(Fixture.id("/missing"))
        #expect(try repository.bookmarks().isEmpty)
    }

    @Test("Bookmarks persist across contexts on the same store")
    func persistence() throws {
        let entry = Fixture.entry("Text")
        try repository.addBookmark(for: entry, at: .now)

        let otherContext = ModelContext(container)
        #expect(try SwiftDataBookmarkRepository(context: otherContext).isBookmarked(entry.id))
    }

    @Test("Bookmarks saved in the old format are still listed, and rewritten in the stored format")
    func migratesLegacyRecords() throws {
        let entry = Fixture.entry("List", path: "/documentation/swiftui/list")
        let legacy = try JSONEncoder().encode(entry) // Version 0: the domain type's own Codable shape.
        container.mainContext.insert(BookmarkRecord(key: entry.id.storageKey, title: entry.title, createdAt: .now, entryPayload: legacy))
        try container.mainContext.save()

        #expect(try repository.bookmarks().map(\.entry) == [entry])

        let record = try #require(try container.mainContext.fetch(FetchDescriptor<BookmarkRecord>()).first)
        #expect(try !EntryPayloadCoder.decode(record.entryPayload).needsMigration)
    }
}
