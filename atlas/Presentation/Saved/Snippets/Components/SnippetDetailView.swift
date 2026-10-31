import SwiftUI

struct SnippetDetailView: View {
    let snippet: CodeSnippet
    @State private var isEditing = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.stack) {
                SnippetMetaLine(snippet: snippet)
                CodeSnippetView(code: snippet.code, language: snippet.language, title: SnippetMetaLine.header(for: snippet))
            }
            .padding(Spacing.contentMargin)
            .readableWidth()
        }
        .background(AtlasColor.background)
        .navigationTitle(snippet.title)
        .toolbar {
            Button(.snippetEditButton) { isEditing = true }
        }
        .sheet(isPresented: $isEditing) {
            SnippetEditorView(snippet: snippet)
        }
    }
}
