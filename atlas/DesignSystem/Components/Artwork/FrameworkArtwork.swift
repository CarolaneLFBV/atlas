import SwiftUI

struct FrameworkArtwork: View {
    let frameworkName: String
    var size: CGFloat = 72

    var body: some View {
        let tint = FrameworkIdentity.of(frameworkName).tint
        switch FrameworkIdentity.normalizedKey(frameworkName) {
        case "swiftdata": NodeGraphArtwork(tint: tint, size: size)
        case "vision": ConcentricRingsArtwork(tint: tint, size: size)
        default: LayeredPlanesArtwork(tint: tint, planeWidth: size * 0.8)
        }
    }
}

#if DEBUG
#Preview {
    HStack(spacing: Spacing.s24) {
        FrameworkArtwork(frameworkName: "SwiftData")
        FrameworkArtwork(frameworkName: "Vision")
        FrameworkArtwork(frameworkName: "Swift Evolution")
    }
    .padding()
}
#endif
