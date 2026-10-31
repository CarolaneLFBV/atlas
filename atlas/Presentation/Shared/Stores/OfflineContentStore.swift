import Foundation
import Observation
import OSLog

@Observable
final class OfflineContentStore {
    private static let logger = Logger(subsystem: "atlas", category: "OfflineContent")

    struct Progress: Equatable {
        var completed: Int
        var total: Int

        var fraction: Double { total > 0 ? Double(completed) / Double(total) : 0 }
    }

    private(set) var statuses: [OfflineContentStatus] = []
    private(set) var progress: [DocumentationSourceID: Progress] = [:]
    private(set) var lastError: String?

    private let downloadContent: DownloadOfflineContentUseCase?

    /// - Parameter downloadContent: `nil` when the documentation layer has no downloadable sources.
    init(downloadContent: DownloadOfflineContentUseCase?) {
        self.downloadContent = downloadContent
    }

    func isDownloading(_ id: DocumentationSourceID) -> Bool {
        progress[id] != nil
    }

    func reload() async {
        guard let downloadContent else { return }
        do {
            statuses = try await downloadContent.statuses()
        } catch {
            Self.logger.error("Reading offline status failed: \(error)")
            lastError = error.documentationUserMessage
        }
    }

    func download(_ id: DocumentationSourceID) async {
        guard let downloadContent, !isDownloading(id) else { return }
        progress[id] = Progress(completed: 0, total: 0)
        do {
            try await downloadContent.download(id) { [weak self] completed, total in
                self?.progress[id] = Progress(completed: completed, total: total)
            }
            lastError = nil
        } catch is CancellationError {
        } catch {
            lastError = error.documentationUserMessage
        }
        progress[id] = nil
        await reload()
    }

    /// Downloads sources never downloaded or not checked recently. Called once at launch;
    /// unchanged pages cost a `304` each, so routine checks are cheap.
    func downloadIfNeeded() async {
        guard let downloadContent else { return }
        await reload()
        let sources: [OfflineContentStatus]
        do {
            sources = try await downloadContent.sourcesNeedingDownload()
        } catch {
            Self.logger.error("Checking which sources need a download failed: \(error)")
            return
        }
        for status in sources {
            await download(status.id)
        }
    }
}
