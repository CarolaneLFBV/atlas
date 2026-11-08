import SwiftUI

/// Decorative only.
struct LayeredPlanesArtwork: View {
    let tint: Color
    /// Width of one plane; the composition is about 1.3× wider and taller.
    var planeWidth: CGFloat = 150
    /// Faint variant for backgrounds (detail headers, top-hit cards): no front plane, low opacity.
    var isFaint = false

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
                LayeredPlanesFrontPlane(tint: tint, planeWidth: planeWidth, planeHeight: planeHeight, radius: radius)
                    .offset(x: -offset, y: offset)
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
