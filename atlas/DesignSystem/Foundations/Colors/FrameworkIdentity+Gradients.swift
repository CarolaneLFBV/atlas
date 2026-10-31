import SwiftUI

extension FrameworkIdentity {
    /// Featured-card tint: 5% → 18% of the framework color at 135°.
    var featuredGradient: LinearGradient {
        LinearGradient(colors: [tint.opacity(0.05), tint.opacity(0.18)], startPoint: .topLeading, endPoint: .bottomTrailing)
    }

    /// The soft band behind page headers: `strength` of the framework color fading to clear.
    func headerBand(strength: Double = 0.12) -> LinearGradient {
        LinearGradient(colors: [tint.opacity(strength), tint.opacity(0)], startPoint: .top, endPoint: .bottom)
    }

    /// The 0.5 pt ring around tinted cards.
    var ring: Color { tint.opacity(0.2) }
}
