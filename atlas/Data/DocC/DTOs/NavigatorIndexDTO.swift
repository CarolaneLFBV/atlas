import Foundation

nonisolated struct NavigatorIndexDTO: Decodable, Sendable {
    nonisolated struct Node: Decodable, Sendable {
        let title: String?
        let path: String?
        let type: String?
        let deprecated: Bool?
        let children: [Node]?
    }

    let interfaceLanguages: [String: [Node]]?
}
