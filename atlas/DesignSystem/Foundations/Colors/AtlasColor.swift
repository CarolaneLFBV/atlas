import SwiftUI

/// Values live in the asset catalog (`Colors/`) with light and dark appearances, so they work on iOS and macOS.
enum AtlasColor {
    // MARK: Surfaces

    static let background = Color(.backgroundPrimary)
    /// Sidebar and grouped backgrounds.
    static let secondaryBackground = Color(.backgroundSecondary)
    /// Cards, lists and the reading page.
    static let surface = Color(.surface)
    static let codeBackground = Color(.codeBackground)
    /// Search fields, chips and badges.
    static let fill = Color(.fill)
    static let selection = Color(.selection)
    static let separator = Color(.separator)

    // MARK: Text

    static let primaryText = Color(.textPrimary)
    static let secondaryText = Color(.textSecondary)
    /// Chevrons, line numbers and inactive items.
    static let tertiaryText = Color(.textTertiary)

    // MARK: Accent and status

    /// Atlas Indigo: links, selection, bookmarks and buttons. Nothing else is tinted with it.
    static let accent = Color(.accent)

    /// Confirmations ("Copied").
    static let success = Color(.success)
    static let successFill = Color(.successFill)
    /// Offline, cached and beta states.
    static let warning = Color(.warning)
    static let warningText = Color(.warningText)
    static let warningFill = Color(.warningFill)
    /// Deprecation and errors.
    static let danger = Color(.danger)
    static let dangerText = Color(.dangerText)
    static let dangerFill = Color(.dangerFill)
}
