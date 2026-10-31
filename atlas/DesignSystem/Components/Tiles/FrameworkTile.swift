import SwiftUI

/// `.solid` (white monogram on the tint) marks the framework itself; `.tinted` (tint on 12% tint)
/// is used in grids and rows.
struct FrameworkTile: View {
    enum Style {
        case solid
        case tinted
    }

    let identity: FrameworkIdentity
    var size: CGFloat = 30
    var style: Style = .tinted

    init(_ name: String?, size: CGFloat = 30, style: Style = .tinted) {
        identity = FrameworkIdentity.of(name)
        self.size = size
        self.style = style
    }

    var body: some View {
        MonogramTile(text: identity.monogram, tint: identity.tint, size: size, style: style)
            .accessibilityHidden(true)
    }
}

#if DEBUG
#Preview {
    HStack(spacing: Spacing.stack) {
        FrameworkTile("SwiftUI", size: 52, style: .solid)
        FrameworkTile("SwiftData", size: 36, style: .solid)
        FrameworkTile("Foundation")
        FrameworkTile("Swift Evolution")
        FrameworkTile("SomeNewKit", size: 22)
    }
    .padding()
}
#endif
