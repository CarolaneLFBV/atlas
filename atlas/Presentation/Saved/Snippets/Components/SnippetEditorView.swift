import SwiftUI

/// Code is stored as text and never executed.
struct SnippetEditorView: View {
    @State private var draft: CodeSnippet
    @Environment(SnippetsStore.self) private var snippets
    @Environment(\.dismiss) private var dismiss

    init(snippet: CodeSnippet) {
        _draft = State(initialValue: snippet)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section(.snippetEditorTitleHeader) {
                    TextField(.snippetUntitled, text: $draft.title)
                }
                Section(.snippetEditorLanguageHeader) {
                    TextField("swift" as String, text: $draft.language)
                        .autocorrectionDisabled()
                }
                Section(.snippetEditorCodeHeader) {
                    TextEditor(text: $draft.code)
                        .font(.atlasCode)
                        .autocorrectionDisabled()
                        #if os(iOS)
                        .textInputAutocapitalization(.never)
                        #endif
                        .frame(minHeight: 200)
                        .accessibilityIdentifier("snippetEditor.code")
                }
                if let error = snippets.lastError {
                    Text(error).foregroundStyle(AtlasColor.danger)
                }
            }
            .navigationTitle(draft.title.isEmpty ? String(localized: .snippetEditorNewTitle) : draft.title)
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(.snippetEditorCancelButton, role: .cancel) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(.snippetEditorSaveButton) {
                        if snippets.save(draft) { dismiss() }
                    }
                    .disabled(draft.code.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}
