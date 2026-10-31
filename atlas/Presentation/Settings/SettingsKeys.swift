import Foundation

nonisolated enum SettingsKeys {
    /// Whether Atlas may load pages from developer.apple.com. Off by default; see docs/DocumentationSources.md.
    static let appleContentFetchingEnabled = "settings.appleContentFetchingEnabled"
    /// Sources the user turned off (`StringSetPreference`, source IDs).
    static let turnedOffSources = "settings.turnedOffSources"
    /// Catalogue categories hidden from the Library (`StringSetPreference`, category names).
    static let hiddenCategories = "settings.hiddenCategories"
}
