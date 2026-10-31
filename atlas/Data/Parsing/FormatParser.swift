import Foundation

/// Adding a format means adding a conformer (and a `SourceFormat` case); caching, search and
/// offline download don't change.
///
/// Called through `SourceParser`, which runs it off the main actor.
nonisolated protocol FormatParser: Sendable {
    func catalogueCategories(from data: Data, source: any DocumentationSource) async throws -> [DocumentationCatalogue.Category]

    /// - Parameter metadata: Entry already known for the page (from the index), used where the page itself is terser.
    func detail(
        from data: Data, id: DocumentationID, metadata: DocumentationEntry?, source: any DocumentationSource
    ) async throws -> DocumentationDetail

    func searchEntries(from data: Data, source: any DocumentationSource, frameworkName: String?) async throws -> [DocumentationEntry]

    /// Exact data URLs and versions declared by a source's index; empty when the index doesn't declare them.
    func pageLocations(fromIndex data: Data, source: any DocumentationSource) async throws -> [DocumentationID: PageLocation]
}

nonisolated extension FormatParser {
    func pageLocations(fromIndex data: Data, source: any DocumentationSource) async throws -> [DocumentationID: PageLocation] {
        [:]
    }
}
