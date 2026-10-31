import Foundation

/// Only the fields Atlas uses are decoded, and every field is optional so a schema change in
/// one part of a page degrades that part instead of failing the whole page.
/// Schema reference: https://github.com/swiftlang/swift-docc (RenderNode.spec.json).
nonisolated struct RenderNodeDTO: Decodable, Sendable {
    nonisolated struct Identifier: Decodable, Sendable {
        let url: String
    }

    nonisolated struct Metadata: Decodable, Sendable {
        nonisolated struct Module: Decodable, Sendable {
            let name: String
        }

        nonisolated struct Platform: Decodable, Sendable {
            let name: String?
            let introducedAt: String?
            let deprecatedAt: String?
            let message: String?
            let beta: Bool?
        }

        let title: String?
        let role: String?
        let roleHeading: String?
        let symbolKind: String?
        let modules: [Module]?
        let platforms: [Platform]?
    }

    let identifier: Identifier
    let kind: String?
    let metadata: Metadata?
    let abstract: [RenderInlineDTO]?
    let primaryContentSections: [PrimaryContentSectionDTO]?
    let topicSections: [TopicSectionDTO]?
    let relationshipsSections: [TopicSectionDTO]?
    let seeAlsoSections: [TopicSectionDTO]?
    let deprecationSummary: [RenderBlockDTO]?
    let references: [String: RenderReferenceDTO]?
}
