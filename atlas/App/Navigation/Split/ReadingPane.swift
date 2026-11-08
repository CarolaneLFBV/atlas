import SwiftUI

struct ReadingPane: View {
    @Bindable var navigator: DocumentationNavigator

    var body: some View {
        if let root = navigator.root {
            NavigationStack(path: $navigator.path) {
                DocumentationDestinationView(entry: root)
                    .documentationDestinations()
            }
            .id(root.id)
            .environment(\.openDocumentation, OpenDocumentationAction { navigator.push($0) })
        } else {
            EmptyStateView(
                .readingPaneEmptyTitle,
                systemImage: AtlasSymbol.article,
                message: .readingPaneEmptyMessage
            )
        }
    }
}
