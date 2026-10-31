import Foundation

protocol BookmarkRepository: AnyObject {
    /// Most recently created first.
    func bookmarks() throws -> [Bookmark]
    func isBookmarked(_ id: DocumentationID) throws -> Bool
    /// Re-adding an existing entry keeps a single bookmark.
    func addBookmark(for entry: DocumentationEntry, at date: Date) throws
    func removeBookmark(_ id: DocumentationID) throws
}
