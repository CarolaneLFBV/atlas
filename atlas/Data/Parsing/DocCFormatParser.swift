import Foundation

nonisolated struct DocCFormatParser: FormatParser {
    func catalogueCategories(from data: Data, source: any DocumentationSource) async throws -> [DocumentationCatalogue.Category] {
        try await DocCParser.catalogueCategories(from: data, source: source)
    }

    func detail(
        from data: Data, id: DocumentationID, metadata: DocumentationEntry?, source: any DocumentationSource
    ) async throws -> DocumentationDetail {
        try await DocCParser.detail(from: data, source: source)
    }

    func searchEntries(from data: Data, source: any DocumentationSource, frameworkName: String?) async throws -> [DocumentationEntry] {
        try await DocCParser.searchEntries(from: data, source: source, frameworkName: frameworkName)
    }
}
