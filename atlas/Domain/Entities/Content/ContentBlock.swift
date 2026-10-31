import Foundation

nonisolated indirect enum ContentBlock: Hashable, Codable, Sendable {
    nonisolated enum AsideStyle: String, Hashable, Codable, Sendable {
        case note, tip, important, warning, experiment, deprecated
    }

    case heading(level: Int, text: String)
    case paragraph([InlineElement])
    case code(CodeSnippet)
    case list(ordered: Bool, items: [[ContentBlock]])
    case aside(style: AsideStyle, title: String?, content: [ContentBlock])
    case unsupported(kind: String)
}
