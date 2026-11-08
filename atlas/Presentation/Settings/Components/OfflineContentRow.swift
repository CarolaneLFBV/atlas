import SwiftUI

struct OfflineContentRow: View {
    let status: OfflineContentStatus
    let isDownloading: Bool
    let progress: OfflineContentStore.Progress?
    let download: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.inline) {
            HStack {
                VStack(alignment: .leading, spacing: Spacing.tight) {
                    Text(status.displayName)
                        .font(.atlasRowTitle)
                    Text(subtitle)
                        .font(.atlasCaption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                if isDownloading {
                    ProgressView().controlSize(.small)
                } else {
                    Button(status.downloadedPages > 0 ? .settingsOfflineUpdateButton : .settingsOfflineDownloadButton, action: download)
                        .buttonStyle(.borderless)
                }
            }
            if let progress, progress.total > 0 {
                ProgressView(value: progress.fraction) {
                    Text(.settingsOfflineProgress(completed: progress.completed, total: progress.total))
                        .font(.atlasCaption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .accessibilityElement(children: .combine)
    }

    private var subtitle: String {
        guard status.downloadedPages > 0 else { return String(localized: .settingsOfflineNotDownloaded) }
        let pages = String(localized: .settingsOfflinePagesAvailable(count: status.downloadedPages))
        guard let date = status.lastUpdated else { return pages }
        return pages + " · " + String(localized: .settingsOfflineChecked(date: date.formatted(.relative(presentation: .named))))
    }
}
