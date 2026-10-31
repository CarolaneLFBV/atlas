import Foundation

/// Content may be rendered natively with attribution, downloaded for offline reading and
/// indexed for full-text search. Add an archive by declaring a new static instance below and
/// listing it in `AppDependencies.liveSources()`.
nonisolated struct OpenDocCArchiveSource: DocumentationSource {
    let id: DocumentationSourceID
    let displayName: String
    let permission: RenderingPermission
    let defaultFrameworkName: String?
    let catalogueFormat: CatalogueFormat
    /// Site root that contains `data/`, `index/` and `documentation/`.
    let baseURL: URL?
    /// Path of the archive's root page, used as its catalogue entry.
    let rootPath: String

    let isEnabled = true
    let allowsOfflineDownload = true

    var catalogueURL: URL? { pageDataURL(forPath: rootPath) }

    var searchIndexURL: URL? { baseURL?.appending(path: "index/index.json") }

    func pageDataURL(forPath path: String) -> URL? {
        baseURL?.appending(path: "data").appending(path: path + ".json")
    }

    func webURL(forPath path: String) -> URL? {
        baseURL?.appending(path: path)
    }
}

extension OpenDocCArchiveSource {
    /// *The Swift Programming Language*, from the Apache-2.0 licensed swiftlang/swift-book repository.
    static let swiftBook = OpenDocCArchiveSource(
        id: DocumentationSourceID(rawValue: "swift-book"),
        displayName: "The Swift Programming Language",
        permission: .fullContent(ContentLicense(
            name: "Apache License 2.0",
            url: URL(string: "https://github.com/swiftlang/swift-book/blob/main/LICENSE.txt"),
            attribution: "The Swift Programming Language — © Apple Inc. and the Swift project authors."
        )),
        defaultFrameworkName: "Swift",
        catalogueFormat: .rootPage(category: "Swift Language"),
        baseURL: URL(string: "https://docs.swift.org/swift-book"),
        rootPath: "/documentation/the-swift-programming-language"
    )

    /// The Swift 6 Concurrency Migration Guide, from the Apache-2.0 licensed swiftlang/swift-migration-guide repository.
    static let swiftMigrationGuide = OpenDocCArchiveSource(
        id: DocumentationSourceID(rawValue: "swift-migration-guide"),
        displayName: "Swift 6 Concurrency Migration Guide",
        permission: .fullContent(ContentLicense(
            name: "Apache License 2.0",
            url: URL(string: "https://github.com/swiftlang/swift-migration-guide/blob/main/LICENSE.txt"),
            attribution: "Swift 6 Concurrency Migration Guide — © Apple Inc. and the Swift project authors."
        )),
        defaultFrameworkName: "Swift Concurrency",
        catalogueFormat: .rootPage(category: "Swift Language"),
        baseURL: URL(string: "https://www.swift.org/migration"),
        rootPath: "/documentation/migrationguide"
    )
}
