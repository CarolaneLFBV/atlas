import SwiftUI

struct FeaturedCard: View {
    let title: String
    /// Real figures only; omitted when unknown.
    var subtitle: String?

    private var identity: FrameworkIdentity { .of(title) }

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack {
                Spacer()
                FrameworkArtwork(frameworkName: title, size: 56)
                    .frame(width: 64, height: 56)
            }
            Color.clear.frame(height: Spacing.s4)
            Text(verbatim: title)
                .font(.headline.bold())
                .foregroundStyle(AtlasColor.primaryText)
                .lineLimit(2)
            if let subtitle {
                Text(verbatim: subtitle)
                    .font(.atlasCaption)
                    .foregroundStyle(AtlasColor.secondaryText)
                    .lineLimit(1)
            }
        }
        .padding(Spacing.s16)
        .frame(maxWidth: .infinity, minHeight: Sizing.mediumCardHeight, maxHeight: .infinity, alignment: .bottomLeading)
        .background(identity.featuredGradient)
        .background(AtlasColor.surface)
        .overlay(Radius.shape(Radius.mediumCard).strokeBorder(identity.ring, lineWidth: Sizing.hairline))
        .clipShape(Radius.shape(Radius.mediumCard))
        .contentShape(Radius.shape(Radius.mediumCard))
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isButton)
    }
}

#if DEBUG
#Preview {
    HStack(spacing: Spacing.s12) {
        FeaturedCard(title: "Swift Evolution", subtitle: "Preview fixture")
        FeaturedCard(title: "SwiftData")
    }
    .padding()
    .background(AtlasColor.background)
}
#endif
