import Foundation

nonisolated enum DocumentationError: Error, Equatable, Sendable {
    /// The device is offline and no cached copy exists.
    case offline
    case notFound(DocumentationID)
    case sourceDisabled(DocumentationSourceID)
    case unknownSource(DocumentationSourceID)
    case invalidResponse
    case transport(String)
}
