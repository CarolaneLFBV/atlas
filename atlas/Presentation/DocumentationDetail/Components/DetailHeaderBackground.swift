import SwiftUI

struct DetailHeaderBackground: View {
    let frameworkName: String?
    var strength = 0.12
    /// Height of the band from the top of the screen.
    var height: CGFloat = 440
    var planeWidth: CGFloat = 120
    /// Full (not faint) planes, for framework pages.
    var showsFullPlanes = false

    var body: some View {
        let identity = FrameworkIdentity.of(frameworkName)
        ZStack(alignment: .topTrailing) {
            identity.headerBand(strength: strength)
            LayeredPlanesArtwork(tint: identity.tint, planeWidth: planeWidth, isFaint: !showsFullPlanes)
                // Below the navigation bar, beside the header.
                .offset(x: showsFullPlanes ? 50 : 40, y: showsFullPlanes ? 110 : 100)
        }
        .frame(height: height)
        .frame(maxWidth: .infinity)
        .clipped()
        .accessibilityHidden(true)
    }
}
