import SwiftUI

struct SnippetCard: View {
    let snippet: CodeSnippet
    let edit: () -> Void

    @Environment(SnippetsStore.self) private var snippets
    @Environment(\.showToast) private var showToast

    /// Lines shown in the list; the detail screen shows the rest.
    private let previewLines = 8

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.inline) {
            NavigationLink {
                SnippetDetailView(snippet: snippet)
            } label: {
                VStack(alignment: .leading, spacing: 2) {
                    Text(snippet.title)
                        .font(.atlasRowTitle)
                        .foregroundStyle(AtlasColor.primaryText)
                    SnippetMetaLine(snippet: snippet)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            CodeSnippetView(
                code: snippet.code,
                language: snippet.language,
                title: SnippetMetaLine.header(for: snippet),
                showsLineNumbers: false,
                displayLineLimit: previewLines
            )
        }
        .contextMenu {
            Button(.snippetEditButton, systemImage: "pencil", action: edit)
            Button(.copyButtonCopy, systemImage: AtlasSymbol.copy) {
                Clipboard.copy(snippet.code)
                showToast(.copyButtonToast)
            }
            Button(.snippetDeleteButton, systemImage: "trash", role: .destructive) { snippets.delete(snippet.id) }
        }
    }
}
