import Foundation

struct DownloadOfflineContentUseCase {
    /// Sources are re-checked at most this often when downloads run automatically.
    static let automaticRefreshInterval: TimeInterval = 7 * 24 * 60 * 60

    let repository: any OfflineContentRepository

    func statuses() async throws -> [OfflineContentStatus] {
        try await repository.offlineStatuses()
    }

    @discardableResult
    func download(_ sourceID: DocumentationSourceID, progress: @escaping (Int, Int) -> Void) async throws -> Int {
        try await repository.downloadForOffline(sourceID, progress: progress)
    }

    func sourcesNeedingDownload(now: Date = .now) async throws -> [OfflineContentStatus] {
        try await statuses().filter { status in
            guard status.downloadedPages > 0, let lastUpdated = status.lastUpdated else { return true }
            return now.timeIntervalSince(lastUpdated) > Self.automaticRefreshInterval
        }
    }
}
