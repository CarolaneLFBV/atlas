import Foundation

nonisolated enum SnippetFilter: CaseIterable, Hashable, Sendable {
    case all, userAuthored, documentation

    var title: String {
        switch self {
        case .all: String(localized: .snippetsFilterAll)
        case .userAuthored: String(localized: .snippetsFilterUserAuthored)
        case .documentation: String(localized: .snippetsFilterDocumentation)
        }
    }

    func includes(_ snippet: CodeSnippet) -> Bool {
        switch (self, snippet.origin) {
        case (.all, _), (.userAuthored, .userAuthored), (.documentation, .documentation): true
        default: false
        }
    }
}
