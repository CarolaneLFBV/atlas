import SwiftUI

struct OfflineContentSection: View {
    @Environment(OfflineContentStore.self) private var offlineContent

    var body: some View {
        Section {
            ForEach(offlineContent.statuses) { status in
                OfflineContentRow(
                    status: status,
                    isDownloading: offlineContent.isDownloading(status.id),
                    progress: offlineContent.progress[status.id],
                    download: { Task { await offlineContent.download(status.id) } }
                )
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
}
