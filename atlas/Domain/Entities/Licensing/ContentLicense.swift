import Foundation

nonisolated struct ContentLicense: Hashable, Codable, Sendable {
    let name: String
    let url: URL?
    let attribution: String
}
