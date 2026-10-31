import Foundation

nonisolated enum PrimaryContentSectionDTO: Decodable, Sendable {
    case declarations([DeclarationDTO])
    case content([RenderBlockDTO])
    case unknown

    private enum CodingKeys: String, CodingKey {
        case kind, declarations, content
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        switch try container.decodeIfPresent(String.self, forKey: .kind) {
        case "declarations":
            self = .declarations(try container.decodeIfPresent([DeclarationDTO].self, forKey: .declarations) ?? [])
        case "content":
            self = .content(try container.decodeIfPresent([RenderBlockDTO].self, forKey: .content) ?? [])
        default:
            self = .unknown
        }
    }
}
