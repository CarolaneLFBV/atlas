import SwiftUI

/// Always used with continuous corners.
enum Radius {
    /// Availability badges and inline code spans.
    static let badge: CGFloat = 6
    /// Copy buttons and small tiles.
    static let button: CGFloat = 7
    /// Search fields and content-list rows.
    static let field: CGFloat = 10
    /// List cards, grid cells, code blocks and declarations.
    static let list: CGFloat = 12
    /// Bookmark and top-hit cards.
    static let card: CGFloat = 16
    static let mediumCard: CGFloat = 18
    static let heroCard: CGFloat = 20

    static func shape(_ radius: CGFloat) -> RoundedRectangle {
        RoundedRectangle(cornerRadius: radius, style: .continuous)
    }
}
