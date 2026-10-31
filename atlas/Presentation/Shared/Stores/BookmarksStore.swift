import Foundation
import Observation

/// Several screens show bookmark state at once (a detail page and the Saved list side by side on iPad),
/// so they observe one store instead of each holding its own copy.
@Observable
final class BookmarksStore {
    private(set) var bookmarks: [Bookmark] = []
    private(set) var lastError: String?

    private let toggleBookmark: ToggleBookmarkUseCase
    private let manageBookmarks: ManageBookmarksUseCase
    private var bookmarkedIDs: Set<DocumentationID> = []

    init(toggleBookmark: ToggleBookmarkUseCase, manageBookmarks: ManageBookmarksUseCase) {
        self.toggleBookmark = toggleBookmark
        self.manageBookmarks = manageBookmarks
        reload()
    }

    func isBookmarked(_ id: DocumentationID) -> Bool {
        bookmarkedIDs.contains(id)
    }

    func toggle(_ entry: DocumentationEntry) {
        perform { try toggleBookmark.execute(for: entry) }
    }

    func remove(_ id: DocumentationID) {
        perform { try manageBookmarks.remove(id) }
    }

    func reload() {
        do {
            bookmarks = try manageBookmarks.bookmarks()
            bookmarkedIDs = Set(bookmarks.map(\.id))
            lastError = nil
        } catch {
            lastError = error.localizedDescription
        }
    }

    private func perform(_ operation: () throws -> Void) {
        do {
            try operation()
            reload()
        } catch {
            lastError = error.localizedDescription
        }
    }
}
