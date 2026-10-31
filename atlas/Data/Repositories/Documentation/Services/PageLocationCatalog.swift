import Foundation

final class PageLocationCatalog {
    private var locationsBySource: [DocumentationSourceID: [DocumentationID: PageLocation]] = [:]

    func hasLocations(for sourceID: DocumentationSourceID) -> Bool {
        locationsBySource[sourceID] != nil
    }

    func update(_ locations: [DocumentationID: PageLocation], for sourceID: DocumentationSourceID) {
        guard !locations.isEmpty else { return }
        locationsBySource[sourceID] = locations
    }

    func location(for id: DocumentationID) -> PageLocation? {
        locationsBySource[id.sourceID]?[id]
    }
}
