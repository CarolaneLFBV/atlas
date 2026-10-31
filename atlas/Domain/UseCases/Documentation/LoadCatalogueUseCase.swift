import Foundation

struct LoadCatalogueUseCase {
    let repository: any DocumentationRepository

    func execute(forceRefresh: Bool = false) async throws -> Fetched<DocumentationCatalogue> {
        if forceRefresh { return try await repository.refreshCatalogue() }
        return try await repository.catalogue()
    }

    /// Sources that are off by default (e.g. for legal reasons), so the UI can explain missing content.
    /// Sources the user turned off themselves aren't listed: their absence is what was asked for.
    var disabledSources: [DocumentationSourceStatus] {
        repository.sourceStatuses.filter { !$0.isEnabled && !$0.isTurnedOffByUser }
    }
}
