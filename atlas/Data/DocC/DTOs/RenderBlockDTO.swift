import Foundation

/// Unknown block types decode to `.unknown(type)`.
nonisolated indirect enum RenderBlockDTO: Decodable, Sendable {
    nonisolated struct ListItem: Decodable, Sendable {
        let content: [RenderBlockDTO]?
    }

    case paragraph([RenderInlineDTO])
    case heading(level: Int, text: String)
    case codeListing(syntax: String?, code: [String])
    case aside(style: String?, name: String?, content: [RenderBlockDTO])
    case unorderedList([ListItem])
    case orderedList([ListItem])
    case unknown(String)

    private enum CodingKeys: String, CodingKey {
        case type, inlineContent, level, text, syntax, code, style, name, content, items
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decodeIfPresent(String.self, forKey: .type) ?? "unknown"
        switch type {
        case "paragraph":
            self = .paragraph(try container.decodeIfPresent([RenderInlineDTO].self, forKey: .inlineContent) ?? [])
        case "heading":
            self = .heading(
                level: try container.decodeIfPresent(Int.self, forKey: .level) ?? 2,
                text: try container.decodeIfPresent(String.self, forKey: .text) ?? ""
            )
        case "codeListing":
            self = .codeListing(
                syntax: try container.decodeIfPresent(String.self, forKey: .syntax),
                code: try container.decodeIfPresent([String].self, forKey: .code) ?? []
            )
        case "aside":
            self = .aside(
                style: try container.decodeIfPresent(String.self, forKey: .style),
                name: try container.decodeIfPresent(String.self, forKey: .name),
                content: try container.decodeIfPresent([RenderBlockDTO].self, forKey: .content) ?? []
            )
        case "unorderedList":
            self = .unorderedList(try container.decodeIfPresent([ListItem].self, forKey: .items) ?? [])
        case "orderedList":
            self = .orderedList(try container.decodeIfPresent([ListItem].self, forKey: .items) ?? [])
        default:
            self = .unknown(type)
        }
    }
}
