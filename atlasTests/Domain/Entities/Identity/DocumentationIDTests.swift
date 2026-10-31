import Testing
@testable import atlas

@Suite("DocumentationID")
struct DocumentationIDTests {
    @Test("Paths are normalized so equivalent references are equal")
    func normalization() {
        let a = DocumentationID(sourceID: .apple, path: "documentation/SwiftUI/View/")
        let b = DocumentationID(sourceID: .apple, path: "/documentation/swiftui/view#overview")
        #expect(a == b)
        #expect(a.path == "/documentation/swiftui/view")
    }

    @Test("DocC reference URIs map to their path")
    func docCReference() throws {
        let id = try #require(DocumentationID(docCReference: "doc://com.apple.SwiftUI/documentation/SwiftUI/View", sourceID: .apple))
        #expect(id.path == "/documentation/swiftui/view")
    }

    @Test("Non-DocC strings are rejected", arguments: ["https://developer.apple.com/documentation/swiftui", "", "SwiftUI"])
    func invalidReference(_ value: String) {
        #expect(DocumentationID(docCReference: value, sourceID: .apple) == nil)
    }

    @Test("Storage keys round-trip")
    func storageKeyRoundTrip() throws {
        let id = DocumentationID(sourceID: DocumentationSourceID(rawValue: "swift-book"), path: "/documentation/tspl/closures")
        let decoded = try #require(DocumentationID(storageKey: id.storageKey))
        #expect(decoded == id)
    }

    @Test("Same path from different sources is a different entry")
    func sourceIsPartOfIdentity() {
        #expect(Fixture.id("/a") != Fixture.id("/a", source: DocumentationSourceID(rawValue: "other")))
    }
}
