import Foundation
import Testing
@testable import atlas

@Suite("DocumentationReferenceURL")
struct DocumentationReferenceURLTests {
    @Test("A reference survives the round trip through its in-app URL")
    func roundTrip() throws {
        let id = Fixture.id("/documentation/swiftui/navigationstack")
        let url = try #require(DocumentationReferenceURL.url(for: id, title: "NavigationStack & friends"))
        let entry = try #require(DocumentationReferenceURL.entry(from: url))
        #expect(entry.id == id)
        #expect(entry.title == "NavigationStack & friends")
    }

    @Test("Other links are not references")
    func externalLinks() throws {
        #expect(DocumentationReferenceURL.entry(from: try #require(URL(string: "https://www.swift.org"))) == nil)
    }
}
