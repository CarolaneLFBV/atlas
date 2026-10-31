import SwiftUI

struct DocumentationLink<Label: View>: View {
    let entry: DocumentationEntry
    @ViewBuilder var label: () -> Label

    @Environment(\.openDocumentation) private var openDocumentation

    var body: some View {
        Button {
            openDocumentation(entry)
        } label: {
            HStack(spacing: Spacing.inline) {
                label()
                Spacer(minLength: 0)
                Image(systemName: AtlasSymbol.disclosure)
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(AtlasColor.tertiaryText)
                    .accessibilityHidden(true)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .documentationContextMenu(for: entry)
    }
}

extension DocumentationLink where Label == DocumentationRow {
    init(entry: DocumentationEntry, showsFramework: Bool = true) {
        self.init(entry: entry) { DocumentationRow(entry: entry, showsFramework: showsFramework) }
    }
}
