import Foundation

/// Decodes and maps DocC JSON off the main actor. Pages can weigh over a megabyte.
nonisolated enum DocCParser {
    @concurrent
    static func detail(from data: Data, source: any DocumentationSource) async throws -> DocumentationDetail {
        RenderNodeMapper(source: source).detail(from: try decode(RenderNodeDTO.self, from: data))
    }

    @concurrent
    static func catalogueCategories(from data: Data, source: any DocumentationSource) async throws -> [DocumentationCatalogue.Category] {
        let mapper = CatalogueMapper(source: source)
        switch source.catalogueFormat {
        case .technologies:
            return mapper.categories(from: try decode(TechnologiesDTO.self, from: data))
        case .rootPage(let category):
            return mapper.categories(fromRootPage: try decode(RenderNodeDTO.self, from: data), category: category)
        }
    }

    @concurrent
    static func searchEntries(from data: Data, source: any DocumentationSource, frameworkName: String? = nil) async throws -> [DocumentationEntry] {
        CatalogueMapper(source: source).searchEntries(from: try decode(NavigatorIndexDTO.self, from: data), frameworkName: frameworkName)
    }

    private static func decode<T: Decodable>(_ type: T.Type, from data: Data) throws -> T {
        do {
            return try JSONDecoder().decode(type, from: data)
        } catch {
            throw DocumentationError.invalidResponse
        }
    }
}
