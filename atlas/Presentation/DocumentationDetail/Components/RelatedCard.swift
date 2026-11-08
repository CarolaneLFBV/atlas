import SwiftUI

struct RelatedCard: View {
    let entry: DocumentationEntry

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.s8) {
            KindTile(kind: entry.kind, frameworkName: entry.frameworkName, size: 26)
            Text(entry.title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(AtlasColor.primaryText)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
            KindTile.accessibilityName(for: entry.kind)
                .font(.atlasCaption)
                .foregroundStyle(AtlasColor.secondaryText)
        }
        .frame(width: 168, alignment: .leading)
        .frame(maxHeight: .infinity, alignment: .topLeading)
        .cardSurface(padding: Spacing.s12, fill: AtlasColor.background)
        .accessibilityElement(children: .combine)
    }
}
