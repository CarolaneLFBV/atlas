import Foundation

nonisolated enum DocumentationKind: Hashable, Codable, Sendable {
    case framework
    case symbol(SymbolKind)
    case article
    case tutorial
    case sampleCode
    case collection
    case unknown
}
