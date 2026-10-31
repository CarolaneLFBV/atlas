import SwiftUI

/// Apply them with `atlasAnimation(_:value:)` so Reduce Motion is respected everywhere.
enum Motion {
    /// Content transitions (loading → loaded).
    static let standard = Animation.smooth(duration: 0.3)
    static let toast = Animation.spring(response: 0.4, dampingFraction: 0.8)
}
