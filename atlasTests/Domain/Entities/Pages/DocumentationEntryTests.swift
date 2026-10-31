import Foundation
import Testing
@testable import atlas

@Suite("DocumentationEntry")
struct DocumentationEntryTests {
    @Test("Entries saved before deprecation tracking still decode, as not deprecated")
    func decodesLegacyPayloads() throws {
        let encoded = try JSONEncoder().encode(Fixture.entry("Text"))
        var object = try #require(try JSONSerialization.jsonObject(with: encoded) as? [String: Any])
        object.removeValue(forKey: "isDeprecated")
        let legacy = try JSONSerialization.data(withJSONObject: object)

        let entry = try JSONDecoder().decode(DocumentationEntry.self, from: legacy)

        #expect(entry.title == "Text")
        #expect(!entry.isDeprecated)
    }

    @Test("Deprecation survives encoding and removing prose")
    func roundTrip() throws {
        let entry = DocumentationEntry(id: Fixture.id("/old"), title: "Old", kind: .article, abstract: "Text", isDeprecated: true)
        let decoded = try JSONDecoder().decode(DocumentationEntry.self, from: JSONEncoder().encode(entry))
        #expect(decoded.isDeprecated)
        #expect(entry.withoutProse().isDeprecated)
    }
}
