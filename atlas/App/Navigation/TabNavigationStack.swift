import SwiftUI

/// It owns its path, so each tab keeps its own history.
struct TabNavigationStack<Root: View>: View {
    @ViewBuilder var root: () -> Root
    @State private var navigator = DocumentationNavigator()

    var body: some View {
        NavigationStack(path: $navigator.path) {
            root()
                .documentationDestinations()
        }
        .environment(\.openDocumentation, OpenDocumentationAction { navigator.push($0) })
    }
}
