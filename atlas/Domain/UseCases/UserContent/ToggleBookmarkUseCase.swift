import Foundation

struct ToggleBookmarkUseCase {
    let repository: any BookmarkRepository
    var now: @Sendable () -> Date = { .now }

    /// - Returns: `true` if the entry is bookmarked after the call.
    @discardableResult
    func execute(for entry: DocumentationEntry) throws -> Bool {
        if try repository.isBookmarked(entry.id) {
            try repository.removeBookmark(entry.id)
            return false
        }
        try repository.addBookmark(for: entry, at: now())
        return true
    }
}
