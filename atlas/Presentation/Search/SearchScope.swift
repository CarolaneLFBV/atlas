import Foundation

nonisolated enum SearchScope: CaseIterable, Hashable, Sendable {
    case all, frameworks, symbols, articles

    var title: String {
        switch self {
        case .all: String(localized: .searchScopeAll)
        case .frameworks: String(localized: .searchScopeFrameworks)
        case .symbols: String(localized: .searchScopeSymbols)
        case .articles: String(localized: .searchScopeArticles)
        }
    }
}
