import SwiftUI

struct FeaturedFrameworkLink<Label: View>: View {
    let framework: DocumentationFramework
    @ViewBuilder let label: Label

    @Environment(\.openDocumentation) private var openDocumentation

    var body: some View {
        Button {
            openDocumentation(framework.entry)
        } label: {
            label
        }
        .buttonStyle(.plain)
        .documentationContextMenu(for: framework.entry)
        .accessibilityIdentifier("library.framework.\(framework.title)")
    }
}
