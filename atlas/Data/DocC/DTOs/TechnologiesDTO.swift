import Foundation

nonisolated struct TechnologiesDTO: Decodable, Sendable {
    nonisolated struct Section: Decodable, Sendable {
        let kind: String?
        let groups: [Group]?
    }

    nonisolated struct Group: Decodable, Sendable {
        let name: String?
        let technologies: [Technology]?
    }

    nonisolated struct Technology: Decodable, Sendable {
        nonisolated struct Destination: Decodable, Sendable {
            let identifier: String?
        }

        let title: String?
        let tags: [String]?
        let destination: Destination?
    }

    let sections: [Section]?
    let references: [String: RenderReferenceDTO]?
}
