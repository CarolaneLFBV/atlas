import CoreGraphics

/// Prefer the semantic tokens in views; use the raw scale only when no semantic token fits.
nonisolated enum Spacing {
    // MARK: Scale

    static let s4: CGFloat = 4
    static let s8: CGFloat = 8
    static let s12: CGFloat = 12
    static let s16: CGFloat = 16
    static let s20: CGFloat = 20
    static let s24: CGFloat = 24
    static let s28: CGFloat = 28
    static let s32: CGFloat = 32
    static let s40: CGFloat = 40
    static let s48: CGFloat = 48
    static let s64: CGFloat = 64

    // MARK: Semantic

    /// Between tightly related elements (icon and label, title and subtitle).
    static let tight = s4
    /// Between elements inside a component.
    static let inline = s8
    /// Between stacked rows or text blocks inside a card.
    static let stack = s12
    static let cardPadding = s16
    /// Horizontal screen margins on iPhone.
    static let contentMargin = s16
    /// Horizontal margins of the iPad reading pane.
    static let readingMargin = s40
    /// Between sections of a browsing screen (Library, Bookmarks).
    static let screenSection = s20
    /// Between sections of a documentation page.
    static let section = s28
    /// Around empty and error states.
    static let stateInset = s40
}
