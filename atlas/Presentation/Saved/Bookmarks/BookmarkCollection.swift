import Foundation

nonisolated struct BookmarkCollection: Sendable {
    /// Bookmarks of one framework, newest first.
    nonisolated struct Group: Identifiable, Sendable {
        var id: String { frameworkName }
        let frameworkName: String
        let bookmarks: [Bookmark]
    }

    /// Name used for entries without a framework.
    static let otherFrameworkName = String(localized: .bookmarksOtherFramework)

    /// All bookmarks, newest first.
    let bookmarks: [Bookmark]

    init(_ bookmarks: [Bookmark]) {
        self.bookmarks = bookmarks.sorted { $0.createdAt > $1.createdAt }
    }

    /// Frameworks with bookmarks, most bookmarked first (ties by name), for the filter chips.
    var frameworkNames: [String] {
        let counts = Dictionary(grouping: bookmarks, by: Self.frameworkName).mapValues(\.count)
        return counts.keys.sorted { (counts[$0, default: 0], $1) > (counts[$1, default: 0], $0) }
    }

    /// Bookmarks of `frameworkName`, or all of them when `nil`.
    func filtered(by frameworkName: String?) -> [Bookmark] {
        guard let frameworkName else { return bookmarks }
        return bookmarks.filter { Self.frameworkName(of: $0) == frameworkName }
    }

    /// Groups by framework, in `frameworkNames` order.
    func groups(filteredBy frameworkName: String?) -> [Group] {
        let filtered = filtered(by: frameworkName)
        let byFramework = Dictionary(grouping: filtered, by: Self.frameworkName)
        return frameworkNames.compactMap { name in
            byFramework[name].map { Group(frameworkName: name, bookmarks: $0) }
        }
    }

    private static func frameworkName(of bookmark: Bookmark) -> String {
        bookmark.entry.frameworkName ?? otherFrameworkName
    }
}
