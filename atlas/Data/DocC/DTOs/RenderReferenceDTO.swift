import Foundation

/// Atlas uses `topic` references (links to pages).
nonisolated struct RenderReferenceDTO: Decodable, Sendable {
    let type: String?
    let identifier: String?
    let title: String?
    let kind: String?
    let role: String?
    let url: String?
    let abstract: [RenderInlineDTO]?
    let deprecated: Bool?
}
