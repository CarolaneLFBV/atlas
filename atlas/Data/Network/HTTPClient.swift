import Foundation

/// Minimal HTTP abstraction so data sources can be tested without the network.
nonisolated protocol HTTPClient: Sendable {
    func get(_ url: URL, validators: CacheValidators?) async throws -> ConditionalResponse
}
