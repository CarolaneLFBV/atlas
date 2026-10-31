import Foundation

/// The identity is the pair (source, normalized path). Paths are normalized to lowercase
/// with a leading slash and no trailing slash, so `doc://com.apple.SwiftUI/documentation/SwiftUI/View`
/// and `https://developer.apple.com/documentation/swiftui/view` resolve to the same entry.
nonisolated struct DocumentationID: Hashable, Codable, Sendable, CustomStringConvertible {
    let sourceID: DocumentationSourceID
    let path: String

    init(sourceID: DocumentationSourceID, path: String) {
        self.sourceID = sourceID
        self.path = Self.normalize(path)
    }

    /// Returns `nil` when the string is not a `doc://` URI with a path.
    init?(docCReference: String, sourceID: DocumentationSourceID) {
        guard let components = URLComponents(string: docCReference),
              components.scheme == "doc",
              !components.path.isEmpty
        else { return nil }
        self.init(sourceID: sourceID, path: components.path)
    }

    init?(storageKey: String) {
        guard let separator = storageKey.firstIndex(of: ":") else { return nil }
        let source = String(storageKey[..<separator])
        let path = String(storageKey[storageKey.index(after: separator)...])
        guard !source.isEmpty, !path.isEmpty else { return nil }
        self.init(sourceID: DocumentationSourceID(rawValue: source), path: path)
    }

    /// A single string suitable as a persistence key, e.g. `apple:/documentation/swiftui/view`.
    var storageKey: String { "\(sourceID.rawValue):\(path)" }

    var description: String { storageKey }

    private static func normalize(_ path: String) -> String {
        var result = path.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if let suffixStart = result.firstIndex(where: { $0 == "#" || $0 == "?" }) {
            result = String(result[..<suffixStart])
        }
        if !result.hasPrefix("/") { result = "/" + result }
        while result.count > 1 && result.hasSuffix("/") { result.removeLast() }
        return result
    }
}
