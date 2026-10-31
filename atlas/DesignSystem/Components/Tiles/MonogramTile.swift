import SwiftUI

/// Corner radius is a quarter of the side, as in the handoff.
struct MonogramTile: View {
    let text: String
    let tint: Color
    let size: CGFloat
    let style: FrameworkTile.Style

    var body: some View {
        Text(verbatim: text)
            .font(.system(size: size * (text.count > 1 ? 0.38 : 0.46), weight: .semibold, design: .monospaced))
            .foregroundStyle(style == .solid ? .white : tint)
            .frame(width: size, height: size)
            .background(style == .solid ? tint : tint.opacity(0.13), in: Radius.shape(size * 0.25))
            .atlasShadow(.tile, color: style == .solid && size >= 36 ? tint : .clear)
    }
}
