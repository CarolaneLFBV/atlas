import SwiftUI

struct SnippetsListView: View {
    @Environment(SnippetsStore.self) private var snippets
    @State private var editingSnippet: CodeSnippet?
    @State private var filter: SnippetFilter = .all

    private var visibleSnippets: [CodeSnippet] { snippets.snippets.filter(filter.includes) }

    var body: some View {
        Group {
            if snippets.snippets.isEmpty {
                EmptyStateView(
                    .snippetsEmptyTitle,
                    systemImage: AtlasSymbol.snippets,
                    message: .snippetsEmptyMessage
                ) {
                    Button(.snippetsNewButton, systemImage: AtlasSymbol.add) { editingSnippet = .newUserSnippet() }
                        .buttonStyle(.bordered)
                }
            } else {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: Spacing.s24) {
                        filterBar
                        ForEach(visibleSnippets) { snippet in
                            SnippetCard(snippet: snippet) { editingSnippet = snippet }
                        }
                    }
                    .padding(.horizontal, Spacing.contentMargin)
                    .padding(.bottom, Spacing.s32)
                    .readableWidth()
                }
                .atlasAnimation(value: filter)
            }
        }
        .navigationTitle(.sectionSnippets)
        .background(AtlasColor.background)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(.snippetsNewButton, systemImage: AtlasSymbol.add) { editingSnippet = .newUserSnippet() }
                    .keyboardShortcut("n", modifiers: .command)
                    .accessibilityIdentifier("snippets.new")
            }
        }
        .sheet(item: $editingSnippet) { snippet in
            SnippetEditorView(snippet: snippet)
        }
    }

    private var filterBar: some View {
        ScrollView(.horizontal) {
            HStack(spacing: Spacing.inline) {
                ForEach(SnippetFilter.allCases, id: \.self) { option in
                    FilterChip(
                        title: option.title,
                        count: option == .all ? snippets.snippets.count : nil,
                        isSelected: filter == option
                    ) { filter = option }
                }
            }
        }
        .scrollIndicators(.hidden)
        .scrollClipDisabled()
    }
}

private extension CodeSnippet {
    static func newUserSnippet() -> CodeSnippet {
        CodeSnippet(title: "", language: "swift", code: "", origin: .userAuthored)
    }
}

#if DEBUG
#Preview {
    let dependencies = AppDependencies.inMemory()
    dependencies.snippets.save(CodeSnippet(title: "Fixture snippet", language: "swift", code: "struct Fixture {\n    let value = 42\n}", origin: .userAuthored))
    return NavigationStack { SnippetsListView() }
        .previewEnvironment(dependencies)
}
#endif
