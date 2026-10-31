import Foundation

// Preview-only code: excluded from Release builds.
#if DEBUG
/// Sample data for SwiftUI previews ONLY.
///
/// Titles mirror real API names so layouts can be judged realistically, but every piece of prose
/// is marked as a fixture. Nothing here is documentation content, and production code never uses it.
enum PreviewFixtures {
    static let source = DocumentationSourceID(rawValue: "preview-fixtures")
    static let fixtureProse = "Preview fixture text — not documentation content."

    static func id(_ path: String) -> DocumentationID {
        DocumentationID(sourceID: source, path: path)
    }

    static func entry(_ title: String, kind: DocumentationKind, framework: String) -> DocumentationEntry {
        DocumentationEntry(
            id: id("/fixtures/\(framework)/\(title)"),
            title: title,
            kind: kind,
            frameworkName: framework,
            abstract: fixtureProse,
            webURL: URL(string: "https://developer.apple.com/documentation/\(framework.lowercased())")
        )
    }

    static func framework(_ title: String, category: String) -> DocumentationFramework {
        DocumentationFramework(
            id: id("/fixtures/\(title)"),
            title: title,
            abstract: nil,
            category: category,
            tags: [],
            webURL: URL(string: "https://developer.apple.com/documentation/\(title.lowercased().replacingOccurrences(of: " ", with: ""))")
        )
    }

    static let catalogue = DocumentationCatalogue(
        categories: [
            .init(name: "App Frameworks", frameworks: [
                framework("SwiftUI", category: "App Frameworks"),
                framework("UIKit", category: "App Frameworks"),
                framework("Foundation", category: "App Frameworks"),
                framework("WidgetKit", category: "App Frameworks"),
                framework("App Intents", category: "App Frameworks"),
            ]),
            .init(name: "Data Management", frameworks: [
                framework("SwiftData", category: "Data Management"),
                framework("Core Data", category: "Data Management"),
            ]),
            .init(name: "Machine Learning", frameworks: [
                framework("Core ML", category: "Machine Learning"),
                framework("Vision", category: "Machine Learning"),
            ]),
        ],
        lastUpdated: .now
    )

    static let entries: [DocumentationEntry] = [
        entry("NavigationStack", kind: .symbol(.structure), framework: "SwiftUI"),
        entry("NavigationSplitView", kind: .symbol(.structure), framework: "SwiftUI"),
        entry("View", kind: .symbol(.protocol), framework: "SwiftUI"),
        entry("searchable(text:placement:prompt:)", kind: .symbol(.method), framework: "SwiftUI"),
        entry("ModelContainer", kind: .symbol(.classType), framework: "SwiftData"),
        entry("Preserving your app's model data across launches", kind: .article, framework: "SwiftData"),
    ]

    static var detail: DocumentationDetail {
        let entry = entries[0]
        return DocumentationDetail(
            entry: entry,
            permission: .fullContent(ContentLicense(name: "Preview fixture", url: nil, attribution: "Preview fixture — not documentation content.")),
            declaration: Declaration(language: "swift", tokens: [
                .init(kind: .attribute, text: "@MainActor", reference: nil),
                .init(kind: .text, text: " ", reference: nil),
                .init(kind: .keyword, text: "struct", reference: nil),
                .init(kind: .text, text: " ", reference: nil),
                .init(kind: .identifier, text: "NavigationStack", reference: nil),
                .init(kind: .text, text: "<", reference: nil),
                .init(kind: .genericParameter, text: "Data", reference: nil),
                .init(kind: .text, text: ", ", reference: nil),
                .init(kind: .genericParameter, text: "Root", reference: nil),
                .init(kind: .text, text: "> ", reference: nil),
                .init(kind: .keyword, text: "where", reference: nil),
                .init(kind: .text, text: " Root : ", reference: nil),
                .init(kind: .typeIdentifier, text: "View", reference: nil),
            ]),
            sections: [
                DocumentationSection(title: "Overview", blocks: [
                    .paragraph([.text(fixtureProse + " It shows "), .code("inline code"), .text(", "), .emphasis([.text("emphasis")]), .text(" and "), .strong([.text("strong text")]), .text(".")]),
                    .code(CodeSnippet(title: "Fixture", language: "swift", code: "NavigationStack {\n    List(items) { item in\n        Text(item.name) // fixture\n    }\n}", origin: .documentation(entry.id))),
                    .aside(style: .note, title: nil, content: [.paragraph([.text(fixtureProse)])]),
                    .list(ordered: false, items: [[.paragraph([.text("First fixture item")])], [.paragraph([.text("Second fixture item")])]]),
                ]),
            ],
            topics: [TopicGroup(title: "Related", entries: Array(entries[1...3]))],
            relationships: [TopicGroup(title: "Conforms To", entries: [entries[2]])],
            availability: [
                PlatformAvailability(platform: "iOS", introducedAt: "16.0", deprecatedAt: nil, isBeta: false),
                PlatformAvailability(platform: "macOS", introducedAt: "13.0", deprecatedAt: nil, isBeta: false),
                PlatformAvailability(platform: "visionOS", introducedAt: "1.0", deprecatedAt: nil, isBeta: false),
            ],
            isDeprecated: false
        )
    }
}
#endif
