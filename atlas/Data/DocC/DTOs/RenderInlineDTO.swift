import Foundation

/// Unknown inline types decode to `.unknown` instead of failing.
nonisolated indirect enum RenderInlineDTO: Decodable, Sendable {
    case text(String)
    case codeVoice(String)
    case emphasis([RenderInlineDTO])
    case strong([RenderInlineDTO])
    case reference(identifier: String, overridingTitle: String?)
    case link(destination: String, title: String?)
    case unknown

    private enum CodingKeys: String, CodingKey {
        case type, text, code, inlineContent, identifier, overridingTitle, destination, title
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        switch try container.decodeIfPresent(String.self, forKey: .type) {
        case "text":
            self = .text(try container.decodeIfPresent(String.self, forKey: .text) ?? "")
        case "codeVoice":
            self = .codeVoice(try container.decodeIfPresent(String.self, forKey: .code) ?? "")
        case "emphasis":
            self = .emphasis(try container.decodeIfPresent([RenderInlineDTO].self, forKey: .inlineContent) ?? [])
        case "strong":
            self = .strong(try container.decodeIfPresent([RenderInlineDTO].self, forKey: .inlineContent) ?? [])
        case "reference":
            self = .reference(
                identifier: try container.decode(String.self, forKey: .identifier),
                overridingTitle: try container.decodeIfPresent(String.self, forKey: .overridingTitle)
            )
        case "link":
            self = .link(
                destination: try container.decode(String.self, forKey: .destination),
                title: try container.decodeIfPresent(String.self, forKey: .title)
            )
        default:
            self = .unknown
        }
    }
}
