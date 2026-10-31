import SwiftUI

struct DocumentationContextMenuModifier: ViewModifier {
    let entry: DocumentationEntry
    @Environment(BookmarksStore.self) private var bookmarks

    func body(content: Content) -> some View {
        content.contextMenu {
            let isBookmarked = bookmarks.isBookmarked(entry.id)
            Button(
                isBookmarked ? .bookmarkButtonRemove : .bookmarkButtonAdd,
                systemImage: isBookmarked ? AtlasSymbol.bookmarkFilled : AtlasSymbol.bookmark
            ) {
                bookmarks.toggle(entry)
            }
            if let url = entry.webURL {
                ShareLink(item: url)
                Link(destination: url) {
                    Label(.contextMenuOpenOnWeb, systemImage: AtlasSymbol.openExternal)
                }
            }
        }
    }
}

extension View {
    func documentationContextMenu(for entry: DocumentationEntry) -> some View {
        modifier(DocumentationContextMenuModifier(entry: entry))
    }
}
