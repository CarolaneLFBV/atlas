import SwiftUI

/// Surfaces are separated by a hairline ring; shadows are reserved for
/// identity tiles, artwork planes and floating elements, and take the framework's color.
struct ShadowToken {
    let opacity: Double
    let radius: CGFloat
    let y: CGFloat

    /// Large identity tiles (`0 8 20 framework@30%`).
    static let tile = ShadowToken(opacity: 0.30, radius: 10, y: 8)
    /// The front artwork plane (`0 16 32 framework@22%`).
    static let plane = ShadowToken(opacity: 0.22, radius: 16, y: 16)
    /// Toasts and menus (`0 8 32 black@14%`).
    static let floating = ShadowToken(opacity: 0.14, radius: 16, y: 8)
}
