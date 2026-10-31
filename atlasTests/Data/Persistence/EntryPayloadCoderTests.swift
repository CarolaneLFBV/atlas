import Foundation
import Testing
@testable import atlas

@Suite("EntryPayloadCoder")
struct EntryPayloadCoderTests {
    private static let kinds: [DocumentationKind] = [
        .framework, .article, .tutorial, .sampleCode, .collection, .unknown,
        .symbol(.structure), .symbol(.classType), .symbol(.protocol), .symbol(.method),
        .symbol(.initializer), .symbol(.macro), .symbol(.other("Subscript")),
    ]

    private func entry(kind: DocumentationKind, deprecated: Bool = false) -> DocumentationEntry {
        DocumentationEntry(
            id: Fixture.id("/documentation/swiftui/navigationstack"), title: "NavigationStack", kind: kind,
            frameworkName: "SwiftUI", abstract: "A view that displays a root view.",
            webURL: URL(string: "https://example.com/navigationstack"), keywords: ["navigation"], isDeprecated: deprecated
        )
    }

    @Test("Every kind survives the stored format", arguments: kinds)
    func roundTrip(kind: DocumentationKind) throws {
        let original = entry(kind: kind, deprecated: true)
        let decoded = try EntryPayloadCoder.decode(try EntryPayloadCoder.encode(original))
        #expect(decoded.entry == original)
        #expect(!decoded.needsMigration)
    }

    @Test("The stored format is versioned and independent of property names")
    func storedShape() throws {
        let json = try JSONSerialization.jsonObject(with: EntryPayloadCoder.encode(entry(kind: .symbol(.structure)))) as? [String: Any]
        #expect(json?["version"] as? Int == StoredEntry.currentVersion)
        #expect(json?["kind"] as? String == "symbol.structure")
        #expect(json?["path"] as? String == "/documentation/swiftui/navigationstack")
    }

    @Test("Payloads written before the stored format still decode, and ask to be rewritten")
    func legacyPayloads() throws {
        let original = entry(kind: .symbol(.method))
        let legacy = try JSONEncoder().encode(original) // The domain type's own Codable shape (version 0).
        let decoded = try EntryPayloadCoder.decode(legacy)
        #expect(decoded.entry == original)
        #expect(decoded.needsMigration)
    }

    @Test("Payloads from a newer app version are reported, not misread")
    func futureVersions() {
        let future = Data(#"{"version": 99, "source": "apple", "path": "/x", "title": "X", "kind": "article"}"#.utf8)
        #expect(throws: EntryPayloadCoder.DecodingError.self) { try EntryPayloadCoder.decode(future) }
    }

    @Test("Unknown kind codes read as unknown rather than failing")
    func unknownKinds() throws {
        let payload = Data(#"{"version": 1, "source": "apple", "path": "/x", "title": "X", "kind": "hologram"}"#.utf8)
        #expect(try EntryPayloadCoder.decode(payload).entry.kind == .unknown)
    }
}
