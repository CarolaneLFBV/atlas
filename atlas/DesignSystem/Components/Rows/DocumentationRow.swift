import SwiftUI

/// Symbols are named in SF Mono. Deprecated entries are de-emphasized (struck-through title,
/// secondary color, "Deprecated" badge) so they're recognizable at a glance without hiding them.
struct DocumentationRow: View {
    let entry: DocumentationEntry
    var showsFramework = true
    var showsAbstract = true

    private var isSymbol: Bool {
        if case .symbol = entry.kind { true } else { false }
    }

    var body: some View {
        HStack(spacing: Spacing.stack) {
            KindTile(kind: entry.kind, frameworkName: entry.frameworkName)
                .opacity(entry.isDeprecated ? 0.5 : 1)

            VStack(alignment: .leading, spacing: 2) {
                Text(entry.title)
                    .font(isSymbol ? .atlasDeclaration : .atlasRowTitle)
                    .strikethrough(entry.isDeprecated, color: AtlasColor.secondaryText)
                    .foregroundStyle(entry.isDeprecated ? AtlasColor.secondaryText : AtlasColor.primaryText)
                    .lineLimit(2)
                    .truncationMode(.tail)
                HStack(spacing: Spacing.tight) {
                    if entry.isDeprecated {
                        DeprecatedBadge()
                    }
                    KindTile.accessibilityName(for: entry.kind)
                    if showsFramework, let framework = entry.frameworkName {
                        Text(verbatim: "·")
                        FrameworkMarker(frameworkName: framework)
                    }
                }
                .font(.atlasCaption)
                .foregroundStyle(AtlasColor.secondaryText)
                .lineLimit(1)
                if showsAbstract, let abstract = entry.abstract {
                    InlineMarkdownText(abstract)
                        .font(.atlasSecondary)
                        .foregroundStyle(AtlasColor.secondaryText)
                        .lineLimit(2)
                }
            }
        }
        .padding(.vertical, Spacing.s4 + 2)
        // List separators start under the text, not under the tile.
        .alignmentGuide(.listRowSeparatorLeading) { _ in 28 + Spacing.s12 }
        .frame(minHeight: 48)
        .accessibilityElement(children: .combine)
    }
}

#if DEBUG
#Preview {
    List {
        DocumentationRow(entry: DocumentationEntry(
            id: DocumentationID(sourceID: .apple, path: "/preview/navigationstack"),
            title: "NavigationStack",
            kind: .symbol(.structure),
            frameworkName: "SwiftUI",
            abstract: "Preview fixture abstract."
        ))
        DocumentationRow(entry: DocumentationEntry(
            id: DocumentationID(sourceID: .apple, path: "/preview/navigationview"),
            title: "NavigationView",
            kind: .symbol(.structure),
            frameworkName: "SwiftUI",
            isDeprecated: true
        ))
        DocumentationRow(entry: DocumentationEntry(
            id: DocumentationID(sourceID: .apple, path: "/preview/concurrency"),
            title: "Concurrency",
            kind: .article,
            frameworkName: "The Swift Programming Language"
        ))
    }
}
#endif
