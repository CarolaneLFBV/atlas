import Foundation

nonisolated enum RenderingPermission: Hashable, Codable, Sendable {
    case fullContent(ContentLicense)
    /// Only factual metadata (titles, kinds, structure, links) may be shown; prose is read on the web.
    case metadataOnly

    var allowsProse: Bool {
        if case .fullContent = self { true } else { false }
    }
}
