import SwiftUI

struct EmptyStateView<Actions: View>: View {
    let title: LocalizedStringResource
    let systemImage: String
    let message: LocalizedStringResource?
    @ViewBuilder var actions: () -> Actions

    init(
        _ title: LocalizedStringResource,
        systemImage: String,
        message: LocalizedStringResource? = nil,
        @ViewBuilder actions: @escaping () -> Actions = { EmptyView() }
    ) {
        self.title = title
        self.systemImage = systemImage
        self.message = message
        self.actions = actions
    }

    var body: some View {
        ContentUnavailableView {
            Label(title, systemImage: systemImage)
        } description: {
            if let message { Text(message) }
        } actions: {
            actions()
        }
        .accessibilityIdentifier("state.empty")
    }
}

#if DEBUG
#Preview {
    EmptyStateView("No Bookmarks", systemImage: AtlasSymbol.bookmark, message: "Bookmark pages to find them here.")
}
#endif
