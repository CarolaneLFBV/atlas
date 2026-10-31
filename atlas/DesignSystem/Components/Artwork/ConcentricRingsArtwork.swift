import SwiftUI

/// Decorative only.
struct ConcentricRingsArtwork: View {
    let tint: Color
    var size: CGFloat = 72

    var body: some View {
        ZStack {
            ring(diameter: size, opacity: 0.30)
            ring(diameter: size * 0.67, opacity: 0.55)
            ring(diameter: size * 0.36, opacity: 1)
            Circle().fill(tint).frame(width: size * 0.14, height: size * 0.14)
        }
        .frame(width: size, height: size)
        .accessibilityHidden(true)
    }

    private func ring(diameter: CGFloat, opacity: Double) -> some View {
        Circle().strokeBorder(tint.opacity(opacity), lineWidth: 1.5).frame(width: diameter, height: diameter)
    }
}

#if DEBUG
#Preview {
    ConcentricRingsArtwork(tint: FrameworkIdentity.of("Vision").tint).padding()
}
#endif
