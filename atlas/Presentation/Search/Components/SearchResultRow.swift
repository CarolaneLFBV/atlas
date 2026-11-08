import SwiftUI

struct SearchResultRow: View {
    let result: SearchResult
    let query: String

    private var entry: DocumentationEntry { result.entry }

    private var isSymbol: Bool {
        if case .symbol = entry.kind { true } else { false }
    }

    var body: some View {
        HStack(alignment: .top, spacing: Spacing.s12) {
            KindTile(kind: entry.kind, frameworkName: entry.frameworkName, size: 26)
                .opacity(entry.isDeprecated ? 0.5 : 1)
            VStack(alignment: .leading, spacing: 2) {
                Text(SearchHighlight.highlighted(entry.title, query: query))
                    .font(isSymbol ? .atlasDeclaration : .subheadline.weight(.semibold))
                    .foregroundStyle(entry.isDeprecated ? AtlasColor.secondaryText : AtlasColor.primaryText)
                    .strikethrough(entry.isDeprecated, color: AtlasColor.secondaryText)
                    .lineLimit(2)
                    .truncationMode(.tail)
                SearchResultMeta(entry: entry, match: result.match)
                if case .text(_, let excerpt) = result.match {
                    Text(SearchHighlight.highlighted(excerpt, query: query, emphasizes: true))
                        .font(.atlasSecondary)
                        .foregroundStyle(AtlasColor.secondaryText)
                        .lineLimit(3)
                        .padding(.top, 2)
                }
            }
        }
        .padding(.vertical, Spacing.s4 + 2)
        // List separators start under the text, not under the tile.
        .alignmentGuide(.listRowSeparatorLeading) { _ in 26 + Spacing.s12 }
        .accessibilityElement(children: .combine)
    }
}
