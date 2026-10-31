import SwiftUI

struct FrameworkDot: View {
    let frameworkName: String?
    var size: CGFloat = Sizing.frameworkDot

    var body: some View {
        Circle()
            .fill(FrameworkIdentity.of(frameworkName).tint)
            .frame(width: size, height: size)
            .accessibilityHidden(true)
    }
}

#if DEBUG
#Preview {
    VStack(alignment: .leading) {
        FrameworkMarker(frameworkName: "SwiftUI")
        FrameworkMarker(frameworkName: "Swift Evolution")
    }
    .font(.atlasCaption)
    .foregroundStyle(AtlasColor.secondaryText)
    .padding()
}
#endif
