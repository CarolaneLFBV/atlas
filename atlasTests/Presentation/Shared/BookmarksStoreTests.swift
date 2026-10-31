import Foundation
import Testing
@testable import atlas

@MainActor
@Suite("BookmarksStore")
struct BookmarksStoreTests {
    let repository = FakeBookmarkRepository()

    private func makeStore() -> BookmarksStore {
        BookmarksStore(
            toggleBookmark: ToggleBookmarkUseCase(repository: repository),
            manageBookmarks: ManageBookmarksUseCase(repository: repository)
        )
    }

    @Test("Toggling updates both the list and the lookup")
    func toggle() {
        let store = makeStore()
        let entry = Fixture.entry("List")

        store.toggle(entry)
        #expect(store.isBookmarked(entry.id))
        #expect(store.bookmarks.map(\.entry) == [entry])

        store.toggle(entry)
        #expect(!store.isBookmarked(entry.id))
        #expect(store.bookmarks.isEmpty)
    }

    @Test("Removing from the Saved list clears the bookmark everywhere")
    func remove() {
        let store = makeStore()
        let entry = Fixture.entry("Form")
        store.toggle(entry)

        store.remove(entry.id)

        #expect(!store.isBookmarked(entry.id))
    }

    @Test("Existing bookmarks are loaded on creation")
    func loadsExisting() throws {
        let entry = Fixture.entry("Text")
        try repository.addBookmark(for: entry, at: .now)
        #expect(makeStore().isBookmarked(entry.id))
    }
}
