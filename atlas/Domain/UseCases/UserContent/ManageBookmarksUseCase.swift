import Foundation

/// Adding goes through `ToggleBookmarkUseCase`.
struct ManageBookmarksUseCase {
    let repository: any BookmarkRepository

    /// Most recently created first.
    func bookmarks() throws -> [Bookmark] {
        try repository.bookmarks()
    }

    func remove(_ id: DocumentationID) throws {
        try repository.removeBookmark(id)
    }
}
