import SwiftUI

/// Decorative only.
struct LayeredPlanesArtwork: View {
    let tint: Color
    /// Width of one plane; the composition is about 1.3× wider and taller.
    var planeWidth: CGFloat = 150
    /// Faint variant for backgrounds (detail headers, top-hit cards): no front plane, low opacity.
    var isFaint = false

    @Environment(\.colorScheme) private var colorScheme

    private var planeHeight: CGFloat { planeWidth * 0.7 }
    private var offset: CGFloat { planeWidth * 0.16 }
    private var radius: CGFloat { planeWidth * 0.115 }

    var body: some View {
        ZStack {
            plane(fill: tint.opacity(isFaint ? 0.06 : 0.10), border: .white.opacity(0.8))
                .offset(x: offset, y: -offset)
            plane(fill: tint.opacity(isFaint ? 0.08 : 0.18), border: .white.opacity(0.9))
                .background(.ultraThinMaterial.opacity(isFaint ? 0 : 1), in: Radius.shape(radius))
            if !isFaint {
                front.offset(x: -offset, y: offset)
            }
        }
        .rotationEffect(.degrees(-11))
        .frame(width: planeWidth + offset * 2, height: planeHeight + offset * 2)
        .accessibilityHidden(true)
    }

    private func plane(fill: Color, border: Color) -> some View {
        Radius.shape(radius)
            .fill(fill)
            .strokeBorder(border, lineWidth: 1)
            .frame(width: planeWidth, height: planeHeight)
    }

    private var front: some View {
        VStack(alignment: .leading, spacing: planeWidth * 0.05) {
            Capsule().fill(tint).frame(width: planeWidth * 0.37, height: planeWidth * 0.053)
            Capsule().fill(AtlasColor.primaryText.opacity(0.16)).frame(width: planeWidth * 0.61, height: planeWidth * 0.033)
            Capsule().fill(AtlasColor.primaryText.opacity(0.16)).frame(width: planeWidth * 0.47, height: planeWidth * 0.033)
        }
        .padding(planeWidth * 0.11)
        .frame(width: planeWidth, height: planeHeight, alignment: .topLeading)
        .background(
            colorScheme == .dark ? Color(red: 40 / 255, green: 40 / 255, blue: 46 / 255).opacity(0.92) : .white.opacity(0.87),
            in: Radius.shape(radius)
        )
        .overlay(Radius.shape(radius).strokeBorder(.white.opacity(colorScheme == .dark ? 0.12 : 1), lineWidth: 1))
        .atlasShadow(.plane, color: tint)
    }
}

#if DEBUG
#Preview {
    VStack(spacing: Spacing.s40) {
        LayeredPlanesArtwork(tint: FrameworkIdentity.of("SwiftUI").tint)
        LayeredPlanesArtwork(tint: FrameworkIdentity.of("SwiftUI").tint, planeWidth: 90, isFaint: true)
    }
    .padding()
    .background(AtlasColor.background)
}
#endif
