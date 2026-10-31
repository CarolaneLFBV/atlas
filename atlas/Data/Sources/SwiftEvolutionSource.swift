import Foundation

/// Swift Evolution proposals, from the Apache-2.0 licensed swiftlang/swift-evolution repository.
///
/// - The dashboard feed `evolution.json` (published on download.swift.org) is the catalogue and
///   search index, and lists each proposal file's git SHA, so unchanged proposals are never re-downloaded.
/// - Proposals are Markdown files, read from the repository's raw content.
nonisolated struct SwiftEvolutionSource: DocumentationSource {
    static let rootPath = "/proposals"

    private static let rawBase = URL(string: "https://raw.githubusercontent.com/swiftlang/swift-evolution/main")
    private static let webBase = URL(string: "https://github.com/swiftlang/swift-evolution/blob/main")

    let id = DocumentationSourceID(rawValue: "swift-evolution")
    let displayName = "Swift Evolution"
    let format = SourceFormat.swiftEvolution
    let catalogueFormat = CatalogueFormat.rootPage(category: "Swift Language")
    let defaultFrameworkName: String? = "Swift Evolution"
    let isEnabled = true
    let allowsOfflineDownload = true

    let permission = RenderingPermission.fullContent(ContentLicense(
        name: "Apache License 2.0",
        url: URL(string: "https://github.com/swiftlang/swift-evolution/blob/main/LICENSE.txt"),
        attribution: "Swift Evolution — © Apple Inc. and the Swift project authors."
    ))

    /// The dashboard feed: catalogue, overview page and search index at once.
    var catalogueURL: URL? { URL(string: "https://download.swift.org/swift-evolution/v1/evolution.json") }

    var searchIndexURL: URL? { catalogueURL }

    /// `/proposals` → the dashboard feed; `/proposals/0461-async-function-isolation` → its Markdown file.
    func pageDataURL(forPath path: String) -> URL? {
        if path == Self.rootPath { return catalogueURL }
        return Self.rawBase?.appending(path: path + ".md")
    }

    func webURL(forPath path: String) -> URL? {
        if path == Self.rootPath { return URL(string: "https://www.swift.org/swift-evolution/") }
        return Self.webBase?.appending(path: path + ".md")
    }
}
