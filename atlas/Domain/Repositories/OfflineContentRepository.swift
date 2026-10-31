import Foundation

/// Only sources whose license permits it are downloadable.
protocol OfflineContentRepository: AnyObject {
    func offlineStatuses() async throws -> [OfflineContentStatus]

    /// - Parameter progress: Called with (completed, total) pages as the download advances.
    /// - Returns: The number of pages now available offline.
    @discardableResult
    func downloadForOffline(
        _ sourceID: DocumentationSourceID,
        progress: @escaping (Int, Int) -> Void
    ) async throws -> Int
}
