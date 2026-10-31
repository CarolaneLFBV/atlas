import SwiftUI

/// Decorative only.
struct NodeGraphArtwork: View {
    let tint: Color
    var size: CGFloat = 72

    var body: some View {
        Canvas { context, canvas in
            let center = CGPoint(x: canvas.width / 2, y: canvas.height / 2)
            let reach = canvas.width * 0.36
            let nodes = [CGPoint(x: -1, y: -0.8), CGPoint(x: 1, y: -0.6), CGPoint(x: -0.7, y: 1), CGPoint(x: 0.9, y: 0.9)]
                .map { CGPoint(x: center.x + $0.x * reach, y: center.y + $0.y * reach) }
            var lines = Path()
            for node in nodes {
                lines.move(to: center)
                lines.addLine(to: node)
            }
            context.stroke(lines, with: .color(tint.opacity(0.6)), lineWidth: 1.5)
            for node in nodes {
                let circle = Path(ellipseIn: CGRect(x: node.x - 7, y: node.y - 7, width: 14, height: 14))
                context.fill(circle, with: .color(.white))
                context.stroke(circle, with: .color(tint.opacity(0.6)), lineWidth: 1.5)
            }
            context.fill(Path(ellipseIn: CGRect(x: center.x - 11, y: center.y - 11, width: 22, height: 22)), with: .color(tint))
        }
        .frame(width: size, height: size)
        .accessibilityHidden(true)
    }
}

#if DEBUG
#Preview {
    NodeGraphArtwork(tint: FrameworkIdentity.of("SwiftData").tint).padding()
}
#endif
