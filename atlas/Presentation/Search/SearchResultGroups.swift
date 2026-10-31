import Foundation

/// Search results arranged for display: the best match as a top hit, then frameworks, symbols,
/// articles and passages matched in text, each keeping the ranking order.
nonisolated struct SearchResultGroups: Sendable {
    let topHit: SearchResult?
    let frameworks: [SearchResult]
    let symbols: [SearchResult]
    let articles: [SearchResult]
    let passages: [SearchResult]

    init(_ results: [SearchResult], scope: SearchScope) {
        let metadata = results.filter { $0.match == .metadata }
        let inScope = metadata.filter { Self.kindScope(of: $0) == scope || scope == .all }
        let showsPassages = scope == .all || scope == .articles
        let top = inScope.first
        let rest = inScope.dropFirst()
        topHit = top
        frameworks = rest.filter { Self.kindScope(of: $0) == .frameworks }
        symbols = rest.filter { Self.kindScope(of: $0) == .symbols }
        articles = rest.filter { Self.kindScope(of: $0) == .articles }
        passages = showsPassages ? results.filter { $0.match != .metadata } : []
    }

    var isEmpty: Bool {
        topHit == nil && passages.isEmpty
    }

    static func kindScope(of result: SearchResult) -> SearchScope {
        switch result.entry.kind {
        case .framework: .frameworks
        case .symbol: .symbols
        case .article, .tutorial, .sampleCode, .collection, .unknown: .articles
        }
    }
}
