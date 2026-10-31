import SwiftUI

struct TopicRow: View {
    let entry: DocumentationEntry

    private var isSymbol: Bool {
        if case .symbol = entry.kind { true } else { false }
    }

    var body: some View {
        DocumentationLink(entry: entry) {
            VStack(alignment: .leading, spacing: Spacing.tight) {
                HStack(spacing: Spacing.inline) {
                    Text(entry.title)
                        .font(isSymbol ? .atlasDeclaration : .atlasRowTitle)
                        .foregroundStyle(entry.isDeprecated ? AtlasColor.secondaryText : (isSymbol ? Color(.syntaxType) : AtlasColor.primaryText))
                        .strikethrough(entry.isDeprecated, color: AtlasColor.secondaryText)
                        .multilineTextAlignment(.leading)
                    if entry.isDeprecated {
                        DeprecatedBadge()
                    }
                }
                if let abstract = entry.abstract {
                    InlineMarkdownText(abstract)
                        .font(.subheadline)
                        .foregroundStyle(AtlasColor.secondaryText)
                        .lineLimit(3)
                        .multilineTextAlignment(.leading)
                }
            }
            .padding(.vertical, Spacing.s12)
        }
        .accessibilityElement(children: .combine)
    }
}
