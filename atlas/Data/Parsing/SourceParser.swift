import Foundation

/// The repository only talks to this type, so adding a format never touches caching or search.
nonisolated enum SourceParser {
    @concurrent
    static func catalogueCategories(from data: Data, source: any DocumentationSource) async throws -> [DocumentationCatalogue.Category] {
        try await source.format.parser.catalogueCategories(from: data, source: source)
    }

    /// - Parameter metadata: Entry already known for the page (from the index), used where the page itself is terser.
    @concurrent
    static func detail(
        from data: Data, id: DocumentationID, metadata: DocumentationEntry?, source: any DocumentationSource
    ) async throws -> DocumentationDetail {
        try await source.format.parser.detail(from: data, id: id, metadata: metadata, source: source)
    }

    @concurrent
    static func searchEntries(
        from data: Data, source: any DocumentationSource, frameworkName: String? = nil
    ) async throws -> [DocumentationEntry] {
        try await source.format.parser.searchEntries(from: data, source: source, frameworkName: frameworkName)
    }

    @concurrent
    static func pageLocations(fromIndex data: Data, source: any DocumentationSource) async throws -> [DocumentationID: PageLocation] {
        try await source.format.parser.pageLocations(fromIndex: data, source: source)
    }
}
