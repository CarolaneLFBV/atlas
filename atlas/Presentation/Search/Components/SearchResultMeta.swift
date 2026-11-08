import SwiftUI

struct SearchResultMeta: View {
    let entry: DocumentationEntry
    let match: SearchResult.Match

    var body: some View {
        HStack(spacing: Spacing.tight) {
            if entry.isDeprecated { DeprecatedBadge() }
            if case .text(let sectionTitle, _) = match {
                Text(sectionTitle)
            } else {
                KindTile.accessibilityName(for: entry.kind)
            }
            if let framework = entry.frameworkName {
                Text(verbatim: "·")
                FrameworkMarker(frameworkName: framework)
            }
        }
        .font(.atlasCaption)
        .foregroundStyle(AtlasColor.secondaryText)
        .lineLimit(1)
    }
}
