import Foundation

nonisolated indirect enum InlineElement: Hashable, Codable, Sendable {
    case text(String)
    case code(String)
    case emphasis([InlineElement])
    case strong([InlineElement])
    case reference(DocumentationID, title: String)
    case link(URL, title: String)

    var plainText: String {
        switch self {
        case .text(let text), .code(let text): text
        case .emphasis(let children), .strong(let children): children.map(\.plainText).joined()
        case .reference(_, let title), .link(_, let title): title
        }
    }
}
