import Foundation

nonisolated struct TopicSectionDTO: Decodable, Sendable {
    let title: String?
    let identifiers: [String]?
}
