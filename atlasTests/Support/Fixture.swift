import Foundation
@testable import atlas

/// These are test fixtures, not app data.
enum Fixture {
    static func id(_ path: String, source: DocumentationSourceID = .apple) -> DocumentationID {
        DocumentationID(sourceID: source, path: path)
    }

    static func entry(
        _ title: String,
        path: String? = nil,
        kind: DocumentationKind = .symbol(.structure),
        framework: String? = "SwiftUI",
        keywords: [String] = []
    ) -> DocumentationEntry {
        DocumentationEntry(
            id: id(path ?? "/documentation/test/\(title)"),
            title: title,
            kind: kind,
            frameworkName: framework,
            abstract: "Fixture abstract",
            webURL: nil,
            keywords: keywords
        )
    }

    static func detail(for entry: DocumentationEntry) -> DocumentationDetail {
        DocumentationDetail(
            entry: entry, permission: .metadataOnly, declaration: nil, sections: [],
            topics: [], relationships: [], availability: [], isDeprecated: false
        )
    }
}
