import Foundation
import Testing
@testable import atlas

@Suite("BookmarkCollection")
struct BookmarkCollectionTests {
    private func bookmark(_ title: String, framework: String?, age: TimeInterval) -> Bookmark {
        let entry = DocumentationEntry(
            id: Fixture.id("/documentation/\(title.lowercased())"), title: title,
            kind: .symbol(.structure), frameworkName: framework
        )
        return Bookmark(entry: entry, createdAt: Date(timeIntervalSince1970: 1_000_000 - age))
    }

    private var collection: BookmarkCollection {
        BookmarkCollection([
            bookmark("A", framework: "SwiftUI", age: 30),
            bookmark("B", framework: "SwiftData", age: 10),
            bookmark("C", framework: "SwiftUI", age: 20),
            bookmark("D", framework: nil, age: 40),
        ])
    }

    @Test("Bookmarks are newest first; frameworks are most bookmarked first, then by name")
    func ordering() {
        #expect(collection.bookmarks.map(\.entry.title) == ["B", "C", "A", "D"])
        // SwiftUI has two bookmarks; the one-bookmark frameworks follow alphabetically.
        let singles = [BookmarkCollection.otherFrameworkName, "SwiftData"].sorted()
        #expect(collection.frameworkNames == ["SwiftUI"] + singles)
    }

    @Test("Groups follow the framework order and keep bookmarks newest first")
    func groups() {
        let groups = collection.groups(filteredBy: nil)
        #expect(groups.first?.frameworkName == "SwiftUI")
        #expect(groups.first?.bookmarks.map(\.entry.title) == ["C", "A"])
        #expect(groups.count == 3)
    }

    @Test("Filtering keeps one framework")
    func filtering() {
        #expect(collection.filtered(by: "SwiftData").map(\.entry.title) == ["B"])
        #expect(collection.groups(filteredBy: "SwiftData").map(\.frameworkName) == ["SwiftData"])
    }
}
