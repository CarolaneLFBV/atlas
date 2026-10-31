import Foundation

nonisolated struct PlatformAvailability: Hashable, Codable, Sendable {
    let platform: String
    let introducedAt: String?
    let deprecatedAt: String?
    let isBeta: Bool
}
