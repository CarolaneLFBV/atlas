import SwiftUI

/// Chooses the navigation structure from the horizontal size class, never from the device model:
/// tabs in compact width (iPhone, Slide Over), a three-column split view in regular width (iPad, Mac).
struct RootView: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(OfflineContentStore.self) private var offlineContent
    @Environment(AppDependencies.self) private var dependencies

    var body: some View {
        Group {
            if horizontalSizeClass == .compact {
                CompactRootView(dependencies: dependencies)
            } else {
                SplitRootView(dependencies: dependencies)
            }
        }
        .tint(AtlasColor.accent)
        .toastHost()
        .task { await offlineContent.downloadIfNeeded() }
    }
}

#if DEBUG
#Preview("Compact") {
    RootView()
        .environment(\.horizontalSizeClass, .compact)
        .previewEnvironment()
}

#Preview("Regular") {
    RootView()
        .environment(\.horizontalSizeClass, .regular)
        .previewEnvironment()
}
#endif
