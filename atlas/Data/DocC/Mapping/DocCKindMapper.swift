import Foundation

nonisolated enum DocCKindMapper {
    static func kind(kind: String?, role: String?, symbolKind: String?) -> DocumentationKind {
        switch (kind, role) {
        case (_, "sampleCode"):
            return .sampleCode
        case ("tutorial", _), ("project", _), (_, "tutorial"), (_, "project"):
            return .tutorial
        case ("symbol", "collection"), (_, "module"):
            return .framework
        case ("symbol", _):
            if symbolKind == "module" { return .framework }
            return symbolKind.map { .symbol(SymbolKind(docCIdentifier: $0)) } ?? .symbol(.other("symbol"))
        case (_, "collection"), (_, "collectionGroup"):
            return .collection
        case ("article", _), (_, "article"), (_, "overview"):
            return .article
        default:
            return .unknown
        }
    }

    static func kind(navigatorType type: String?) -> DocumentationKind {
        switch type {
        case "module", "framework": .framework
        case "article", "overview": .article
        case "tutorial", "project", "tutorialArticle": .tutorial
        case "sampleCode": .sampleCode
        case "collection", "collectionGroup", "symbolCollection": .collection
        case nil, "", "groupMarker", "languageGroup": .unknown
        case let symbolKind?: .symbol(SymbolKind(docCIdentifier: symbolKind))
        }
    }
}
