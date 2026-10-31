import SwiftUI

/// The whole card is the tap target (wrap it in a link); the pill only signals it.
struct FeaturedHeroCard: View {
    let title: String
    var eyebrow: LocalizedStringResource = .featuredHeroEyebrow
    /// Real figures only ("560 proposals"); omitted when unknown.
    var subtitle: String?

    private var identity: FrameworkIdentity { .of(title) }

    /// Width the planes artwork covers on the trailing side.
    private static let artworkInset: CGFloat = 120

    var body: some View {
        ZStack(alignment: .topTrailing) {
            LayeredPlanesArtwork(tint: identity.tint, planeWidth: 118)
                .offset(x: 30, y: 6)

            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: Spacing.inline) {
                    FrameworkTile(title, size: 22, style: .solid)
                    Text(eyebrow)
                        .atlasEyebrow()
                        .foregroundStyle(identity.tint)
                }
                Color.clear.frame(height: Spacing.s32) // Room for the artwork above the title.
                Text(verbatim: title)
                    .font(.atlasHeroTitle)
                    .tracking(-0.4)
                    .foregroundStyle(AtlasColor.primaryText)
                    .lineLimit(4)
                    .minimumScaleFactor(0.75)
                    // Keeps the title clear of the artwork in narrow columns.
                    .padding(.trailing, Self.artworkInset)
                if let subtitle {
                    Text(verbatim: subtitle)
                        .font(.atlasSecondary)
                        .foregroundStyle(AtlasColor.secondaryText)
                        .lineLimit(2)
                        .padding(.top, 2)
                        .padding(.trailing, Self.artworkInset)
                }
                Text(.featuredHeroExplore)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(AtlasColor.background)
                    .padding(.horizontal, Spacing.s16)
                    .frame(height: Sizing.chipHeight)
                    .background(AtlasColor.primaryText, in: Capsule())
                    .padding(.top, Spacing.s12)
                    .accessibilityHidden(true)
            }
            .padding(Spacing.s20)
            .frame(maxWidth: .infinity, alignment: .topLeading)
        }
        .frame(minHeight: Sizing.heroCardHeight)
        .background(identity.featuredGradient)
        .background(AtlasColor.surface)
        .overlay(Radius.shape(Radius.heroCard).strokeBorder(identity.ring, lineWidth: Sizing.hairline))
        .clipShape(Radius.shape(Radius.heroCard))
        .contentShape(Radius.shape(Radius.heroCard))
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isButton)
    }
}

#if DEBUG
#Preview {
    FeaturedHeroCard(title: "The Swift Programming Language", subtitle: "Preview fixture · 52 pages")
        .padding()
        .background(AtlasColor.background)
}
#endif
