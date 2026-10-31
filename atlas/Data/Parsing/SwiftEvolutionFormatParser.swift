import Foundation

nonisolated struct SwiftEvolutionFormatParser: FormatParser {
    func catalogueCategories(from data: Data, source: any DocumentationSource) async throws -> [DocumentationCatalogue.Category] {
        let category = if case .rootPage(let name) = source.catalogueFormat { name } else { source.displayName }
        return EvolutionMapper(source: source).catalogueCategories(from: try dashboard(from: data), category: category)
    }

    func detail(
        from data: Data, id: DocumentationID, metadata: DocumentationEntry?, source: any DocumentationSource
    ) async throws -> DocumentationDetail {
        let mapper = EvolutionMapper(source: source)
        if id.path == SwiftEvolutionSource.rootPath {
            return mapper.overview(from: try dashboard(from: data))
        }
        guard let markdown = String(data: data, encoding: .utf8) else { throw DocumentationError.invalidResponse }
        return mapper.proposal(fromMarkdown: markdown, id: id, metadata: metadata)
    }

    func searchEntries(from data: Data, source: any DocumentationSource, frameworkName: String?) async throws -> [DocumentationEntry] {
        EvolutionMapper(source: source).proposalEntries(from: try dashboard(from: data))
    }

    func pageLocations(fromIndex data: Data, source: any DocumentationSource) async throws -> [DocumentationID: PageLocation] {
        EvolutionMapper(source: source).pageLocations(from: try dashboard(from: data))
    }

    private func dashboard(from data: Data) throws -> EvolutionDashboardDTO {
        do {
            return try JSONDecoder().decode(EvolutionDashboardDTO.self, from: data)
        } catch {
            throw DocumentationError.invalidResponse
        }
    }
}
