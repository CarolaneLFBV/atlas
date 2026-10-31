import Foundation

nonisolated enum ValidationError: Error, Equatable, Sendable {
    /// The associated value names the field.
    case emptyField(String)
}
