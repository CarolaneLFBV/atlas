import SwiftUI

/// Opening a page from the content column replaces the reading pane; following a link inside the
/// reading pane pushes onto the pane's own stack, so the content column keeps its place.
struct SplitRootView: View {
    @State private var selection: SidebarItem? = .section(.library)
    @State private var navigator = DocumentationNavigator()
    /// Starts with every column visible: on launch nothing is selected, so an empty reading pane alone would be a dead end.
    @State private var columnVisibility: NavigationSplitViewVisibility = .all
    /// Shares the repository's cache with the Library.
    @State private var catalogue: LibraryViewModel

    init(dependencies: AppDependencies) {
        _catalogue = State(initialValue: LibraryViewModel(loadCatalogue: dependencies.loadCatalogue))
    }

    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            SidebarView(selection: $selection, catalogue: catalogue)
                .navigationSplitViewColumnWidth(min: 220, ideal: 260)
                .toolbar {
                    Button(.sidebarSearchButton, systemImage: AtlasSymbol.search) { selection = .section(.search) }
                        .keyboardShortcut("f", modifiers: .command)
                }
        } content: {
            NavigationStack {
                SplitContentColumn(selection: selection)
            }
            .id(selection)
            .navigationSplitViewColumnWidth(min: 280, ideal: 320)
            .environment(\.openDocumentation, OpenDocumentationAction { navigator.replaceRoot(with: $0) })
        } detail: {
            ReadingPane(navigator: navigator)
        }
        .navigationSplitViewStyle(.balanced)
        .onChange(of: selection) { _, item in
            // A framework's own page opens in the reading pane while its pages list in the content column.
            if case .framework(let framework) = item {
                navigator.replaceRoot(with: framework.entry)
            }
        }
        .environment(\.showSection, ShowSectionAction { selection = .section($0) })
    }
}
