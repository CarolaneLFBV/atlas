import SwiftUI

struct LayeredPlanesFrontPlane: View {
    let tint: Color
    let planeWidth: CGFloat
    let planeHeight: CGFloat
    let radius: CGFloat

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
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
