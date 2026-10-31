import Foundation
@testable import atlas

@MainActor
final class StubOfflineContentRepository: OfflineContentRepository {
    var statuses: [OfflineContentStatus] = []

    func offlineStatuses() async throws -> [OfflineContentStatus] {
        statuses
    }

    func downloadForOffline(_ sourceID: DocumentationSourceID, progress: @escaping (Int, Int) -> Void) async throws -> Int {
        0
    }
}
