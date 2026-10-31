import Foundation

nonisolated enum ConditionalResponse: Sendable {
    /// The resource changed (or was fetched for the first time), with its new validators.
    case modified(Data, CacheValidators)
    case notModified
}
