import SwiftUI

struct DocumentationDetailToolbar: ToolbarContent {
    let webURL: URL?
    let isBookmarked: Bool
    let toggleBookmark: () -> Void

    var body: some ToolbarContent {
        ToolbarItemGroup(placement: .primaryAction) {
            if let webURL {
                ShareLink(item: webURL)
            }
            BookmarkButton(isBookmarked: isBookmarked, action: toggleBookmark)
                .keyboardShortcut("d", modifiers: .command)
        }
        if let webURL {
            ToolbarItem(placement: .secondaryAction) {
                Link(destination: webURL) {
                    Label(.contextMenuOpenOnWeb, systemImage: AtlasSymbol.openExternal)
                }
            }
        }
    }
}
