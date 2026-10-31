import SwiftUI

enum AppSection: String, CaseIterable, Identifiable, Hashable {
    case library, search, bookmarks, snippets, recent, settings

    var id: Self { self }

    var title: LocalizedStringResource {
        switch self {
        case .library: .sectionLibrary
        case .search: .sectionSearch
        case .bookmarks: .sectionBookmarks
        case .snippets: .sectionSnippets
        case .recent: .sectionRecent
        case .settings: .sectionSettings
        }
    }

    var systemImage: String {
        switch self {
        case .library: AtlasSymbol.library
        case .search: AtlasSymbol.search
        case .bookmarks: AtlasSymbol.bookmark
        case .snippets: AtlasSymbol.snippets
        case .recent: AtlasSymbol.recent
        case .settings: AtlasSymbol.settings
        }
    }
}
