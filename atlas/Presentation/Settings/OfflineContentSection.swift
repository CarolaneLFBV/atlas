import SwiftUI

struct OfflineContentSection: View {
    @Environment(OfflineContentStore.self) private var offlineContent

    var body: some View {
        Section {
            ForEach(offlineContent.statuses) { status in
                row(for: status)
            }
            if let error = offlineContent.lastError {
                Text(error)
                    .font(.atlasCaption)
                    .foregroundStyle(AtlasColor.warning)
            }
        } header: {
            Text(.settingsOfflineHeader)
        } footer: {
            Text(.settingsOfflineFooter)
        }
        .task { await offlineContent.reload() }
    }

    private func row(for status: OfflineContentStatus) -> some View {
        VStack(alignment: .leading, spacing: Spacing.inline) {
            HStack {
                VStack(alignment: .leading, spacing: Spacing.tight) {
                    Text(status.displayName)
                        .font(.atlasRowTitle)
                    Text(subtitle(for: status))
                        .font(.atlasCaption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                if offlineContent.isDownloading(status.id) {
                    ProgressView().controlSize(.small)
                } else {
                    Button(status.downloadedPages > 0 ? .settingsOfflineUpdateButton : .settingsOfflineDownloadButton) {
                        Task { await offlineContent.download(status.id) }
                    }
                    .buttonStyle(.borderless)
                }
            }
            if let progress = offlineContent.progress[status.id], progress.total > 0 {
                ProgressView(value: progress.fraction) {
                    Text(.settingsOfflineProgress(completed: progress.completed, total: progress.total))
                        .font(.atlasCaption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .accessibilityElement(children: .combine)
    }

    private func subtitle(for status: OfflineContentStatus) -> String {
        guard status.downloadedPages > 0 else { return String(localized: .settingsOfflineNotDownloaded) }
        let pages = String(localized: .settingsOfflinePagesAvailable(count: status.downloadedPages))
        guard let date = status.lastUpdated else { return pages }
        return pages + " · " + String(localized: .settingsOfflineChecked(date: date.formatted(.relative(presentation: .named))))
    }
}
