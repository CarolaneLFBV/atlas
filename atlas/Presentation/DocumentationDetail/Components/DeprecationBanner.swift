import SwiftUI

struct DeprecationBanner: View {
    let notice: [ContentBlock]
    let replacements: [DocumentationEntry]

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.stack) {
            Label(.deprecationBannerTitle, systemImage: "exclamationmark.octagon")
                .font(.atlasRowTitle)
                .foregroundStyle(AtlasColor.dangerText)

            if notice.isEmpty {
                Text(.deprecationBannerMessage)
                    .font(.atlasBody)
            } else {
                ForEach(Array(notice.enumerated()), id: \.offset) { _, block in
                    ContentBlockView(block: block)
                }
            }

            if !replacements.isEmpty {
                VStack(alignment: .leading, spacing: 0) {
                    Text(.deprecationBannerReplacements)
                        .atlasEyebrow()
                        .foregroundStyle(AtlasColor.secondaryText)
                        .padding(.bottom, Spacing.tight)
                    ForEach(replacements) { entry in
                        DocumentationLink(entry: entry, showsFramework: false)
                            .padding(.vertical, Spacing.tight)
                    }
                }
            }
        }
        .padding(Spacing.cardPadding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AtlasColor.dangerFill, in: Radius.shape(Radius.list))
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("detail.deprecation")
    }
}

#if DEBUG
#Preview {
    DeprecationBanner(
        notice: [.paragraph([.text("Use "), .reference(PreviewFixtures.entries[0].id, title: "NavigationStack"), .text(" instead.")])],
        replacements: [PreviewFixtures.entries[0], PreviewFixtures.entries[1]]
    )
    .padding()
    .previewEnvironment()
}
#endif
