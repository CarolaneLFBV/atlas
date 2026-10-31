import SwiftUI

/// Views call `openDocumentation(entry)` without knowing whether they live in a tab's stack
/// or in a split view column; the container decides by installing the action in the environment.
struct OpenDocumentationAction {
    private let handler: (DocumentationEntry) -> Void

    init(_ handler: @escaping (DocumentationEntry) -> Void) {
        self.handler = handler
    }

    func callAsFunction(_ entry: DocumentationEntry) {
        handler(entry)
    }
}

extension EnvironmentValues {
    @Entry var openDocumentation = OpenDocumentationAction { _ in }
}
