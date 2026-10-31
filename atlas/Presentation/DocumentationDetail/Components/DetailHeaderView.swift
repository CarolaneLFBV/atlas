import SwiftUI

struct DetailHeaderView: View {
    let entry: DocumentationEntry
    var isDeprecated = false

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.s12) {
            if let framework = entry.frameworkName {
                HStack(spacing: Spacing.inline) {
                    FrameworkTile(framework, size: 22, style: .solid)
                    Text(framework)
                        .font(.atlasSecondary.weight(.semibold))
                        .foregroundStyle(FrameworkIdentity.of(framework).tint)
                        .lineLimit(1)
                    if isDeprecated {
                        DeprecatedBadge()
                    }
                }
                .accessibilityElement(children: .combine)
            }

            VStack(alignment: .leading, spacing: Spacing.s8) {
                KindTile.accessibilityName(for: entry.kind)
                    .atlasEyebrow()
                    .foregroundStyle(AtlasColor.secondaryText)
                Text(entry.title)
                    .font(.atlasDocumentTitle)
                    .tracking(-0.5)
                    .foregroundStyle(AtlasColor.primaryText)
                    .textSelection(.enabled)
                    .accessibilityAddTraits(.isHeader)
            }

            if let abstract = entry.abstract {
                InlineMarkdownText(abstract)
                    .font(.atlasAbstract)
                    .lineSpacing(Spacing.tight + 2) // 17 pt on 24 pt lines.
                    .foregroundStyle(AtlasColor.secondaryText)
            }
        }
    }
}

#if DEBUG
#Preview {
    DetailHeaderView(entry: PreviewFixtures.entries[0], isDeprecated: true)
        .padding()
}
#endif
