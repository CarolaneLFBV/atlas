import SwiftUI

struct FrameworkHeaderView: View {
    let detail: DocumentationDetail

    private var pageCount: Int {
        Set((detail.topics.flatMap(\.entries)).map(\.id)).count
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.s12) {
            FrameworkTile(detail.entry.title, size: 52, style: .solid)
            Text(detail.entry.title)
                .font(.atlasScreenTitle)
                .tracking(-0.4)
                .foregroundStyle(AtlasColor.primaryText)
                // Clear of the planes artwork on the trailing side.
                .padding(.trailing, 96)
                .accessibilityAddTraits(.isHeader)
            if let abstract = detail.entry.abstract {
                InlineMarkdownText(abstract)
                    .font(.subheadline)
                    .foregroundStyle(AtlasColor.secondaryText)
                    .frame(maxWidth: 260, alignment: .leading)
            }
            HStack(spacing: Spacing.tight) {
                Text(.frameworkHeaderCounts(
                    topics: String(localized: .frameworkTopicCount(count: detail.topics.count)),
                    pages: String(localized: .frameworkPageCount(count: pageCount))
                ))
                if let platform = detail.availability.first, let introduced = platform.introducedAt {
                    Text(verbatim: "·")
                    FrameworkDot(frameworkName: detail.entry.title)
                    Text(verbatim: "\(platform.platform) \(introduced)+")
                }
            }
            .font(.atlasMonoMeta)
            .foregroundStyle(AtlasColor.secondaryText)
        }
    }
}
