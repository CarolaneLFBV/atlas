import Foundation

nonisolated struct DocumentationSourceID: RawRepresentable, Hashable, Codable, Sendable {
    let rawValue: String

    init(rawValue: String) { self.rawValue = rawValue }

    static let apple = DocumentationSourceID(rawValue: "apple")
}
