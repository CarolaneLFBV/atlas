import Foundation

nonisolated struct DocumentationSourceStatus: Identifiable, Hashable, Sendable {
    let id: DocumentationSourceID
    let displayName: String
    let isEnabled: Bool
    /// Turned off in Settings by the user (rather than off by default for legal reasons).
    var isTurnedOffByUser = false
}
