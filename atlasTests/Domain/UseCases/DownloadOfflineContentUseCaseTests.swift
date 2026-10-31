import Foundation
import Testing
@testable import atlas

@MainActor
@Suite("DownloadOfflineContentUseCase")
struct DownloadOfflineContentUseCaseTests {
    @Test("Never-downloaded and outdated sources need a download; recent ones don't")
    func sourcesNeedingDownload() async throws {
        let now = Date(timeIntervalSince1970: 10_000_000)
        let repository = StubOfflineContentRepository()
        repository.statuses = [
            OfflineContentStatus(id: .init(rawValue: "never"), displayName: "Never", downloadedPages: 0, lastUpdated: nil),
            OfflineContentStatus(id: .init(rawValue: "old"), displayName: "Old", downloadedPages: 5, lastUpdated: now.addingTimeInterval(-8 * 86_400)),
            OfflineContentStatus(id: .init(rawValue: "recent"), displayName: "Recent", downloadedPages: 5, lastUpdated: now.addingTimeInterval(-86_400)),
        ]

        let needing = try await DownloadOfflineContentUseCase(repository: repository).sourcesNeedingDownload(now: now)

        #expect(needing.map(\.displayName) == ["Never", "Old"])
    }
}
