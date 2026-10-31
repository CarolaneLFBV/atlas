import SwiftUI

extension View {
    func atlasShadow(_ token: ShadowToken, color: Color = .black) -> some View {
        shadow(color: color.opacity(token.opacity), radius: token.radius, y: token.y)
    }
}
