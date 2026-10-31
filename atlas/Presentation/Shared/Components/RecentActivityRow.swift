import SwiftUI

struct RecentActivityRow: View {
    let item: RecentActivity

    var body: some View {
        HStack(spacing: Spacing.s12) {
            KindTile(kind: item.entry.kind, frameworkName: item.entry.frameworkName)
            VStack(alignment: .leading, spacing: 2) {
                Text(item.entry.title)
                    .font(.atlasRowTitle)
                    .foregroundStyle(AtlasColor.primaryText)
                    .lineLimit(1)
                Group {
                    if let framework = item.entry.frameworkName {
                        Text(.recentRowSubtitle(framework: framework, date: item.lastOpenedAt.formatted(.relative(presentation: .named))))
                    } else {
                        Text(item.lastOpenedAt, format: .relative(presentation: .named))
                    }
                }
                .font(.atlasSecondary)
                .foregroundStyle(AtlasColor.secondaryText)
                .lineLimit(1)
            }
        }
        .padding(.vertical, Spacing.s8 + 2)
        // List separators start under the text, not under the tile.
        .alignmentGuide(.listRowSeparatorLeading) { _ in 28 + Spacing.s12 }
        .accessibilityElement(children: .combine)
    }
}
