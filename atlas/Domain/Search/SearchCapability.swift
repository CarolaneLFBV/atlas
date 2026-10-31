import Foundation

/// Titles, symbols, frameworks and keywords of every known entry are always searchable.
/// Full text is searchable only for sources whose content has been downloaded.
nonisolated struct SearchCapability: Hashable, Sendable {
    let fullTextSourceNames: [String]

    static let metadata = SearchCapability(fullTextSourceNames: [])

    var includesFullText: Bool { !fullTextSourceNames.isEmpty }
}
