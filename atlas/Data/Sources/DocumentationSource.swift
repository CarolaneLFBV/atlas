import Foundation

/// Sources are descriptors only. Fetching, caching, decoding and permission enforcement are shared
/// by all sources (see `DocumentationSyncService` and `CachedDocumentationRepository`), so adding a
/// source never means re-implementing networking.
nonisolated protocol DocumentationSource: Sendable {
    var id: DocumentationSourceID { get }
    var displayName: String { get }
    var format: SourceFormat { get }
    var permission: RenderingPermission { get }
    /// Whether the source may be contacted right now (e.g. gated by a user setting).
    var isEnabled: Bool { get }
    var catalogueFormat: CatalogueFormat { get }
    var catalogueURL: URL? { get }
    /// A DocC navigator index listing every page, when the source publishes one.
    var searchIndexURL: URL? { get }
    /// Framework name for pages that don't declare a module (e.g. a book).
    var defaultFrameworkName: String? { get }
    /// Whether the whole source may be downloaded and its text indexed for full-text search.
    /// Only true for openly licensed content.
    var allowsOfflineDownload: Bool { get }

    /// A navigator index listing every page of one framework, for sources that publish one per framework.
    /// - Parameter path: The framework's page path, e.g. `/documentation/swiftui`.
    func frameworkIndexURL(forFrameworkPath path: String) -> URL?

    /// The render-JSON URL for a page path such as `/documentation/swiftui/view`.
    func pageDataURL(forPath path: String) -> URL?
    func webURL(forPath path: String) -> URL?
}

nonisolated extension DocumentationSource {
    var format: SourceFormat { .docc }

    func frameworkIndexURL(forFrameworkPath path: String) -> URL? { nil }
}

nonisolated enum CatalogueFormat: Hashable, Sendable {
    case technologies
    /// A single root page shown as one catalogue entry in the named category.
    case rootPage(category: String)
}
