import SwiftUI

struct TopHitCard: View {
    let entry: DocumentationEntry
    let query: String

    @Environment(\.openDocumentation) private var openDocumentation

    private var identity: FrameworkIdentity { .of(entry.frameworkName) }

    var body: some View {
        Button {
            openDocumentation(entry)
        } label: {
            ZStack(alignment: .topTrailing) {
                LayeredPlanesArtwork(tint: identity.tint, planeWidth: 90, isFaint: true)
                    .offset(x: 30, y: -16)
                VStack(alignment: .leading, spacing: Spacing.s8) {
                    HStack(spacing: Spacing.s12) {
                        KindTile(kind: entry.kind, frameworkName: entry.frameworkName, size: 36, style: .solid)
                        Text(.searchTopHit)
                            .atlasEyebrow()
                            .foregroundStyle(identity.tint)
                    }
                    Text(SearchHighlight.highlighted(entry.title, query: query))
                        .font(.title3.bold())
                        .foregroundStyle(entry.isDeprecated ? AtlasColor.secondaryText : AtlasColor.primaryText)
                        .strikethrough(entry.isDeprecated, color: AtlasColor.secondaryText)
                        .multilineTextAlignment(.leading)
                    if let abstract = entry.abstract {
                        InlineMarkdownText(abstract)
                            .font(.subheadline)
                            .foregroundStyle(AtlasColor.secondaryText)
                            .lineLimit(3)
                            .multilineTextAlignment(.leading)
                    }
                    HStack(spacing: Spacing.tight) {
                        if entry.isDeprecated { DeprecatedBadge() }
                        KindTile.accessibilityName(for: entry.kind)
                        if let framework = entry.frameworkName {
                            Text(verbatim: "·")
                            FrameworkMarker(frameworkName: framework)
                        }
                    }
                    .font(.atlasCaption)
                    .foregroundStyle(AtlasColor.secondaryText)
                }
                .padding(Spacing.s16)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .background(identity.featuredGradient)
            .background(AtlasColor.surface)
            .overlay(Radius.shape(Radius.card).strokeBorder(identity.ring, lineWidth: Sizing.hairline))
            .clipShape(Radius.shape(Radius.card))
            .contentShape(Radius.shape(Radius.card))
        }
        .buttonStyle(.plain)
        .documentationContextMenu(for: entry)
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("search.topHit")
    }
}
