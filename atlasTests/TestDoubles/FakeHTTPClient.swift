import Foundation
import Synchronization
@testable import atlas

/// A `Mutex`-protected class rather than an actor: conforming an actor to the `nonisolated`
/// `HTTPClient` protocol is rejected by the current toolchain.
final class FakeHTTPClient: HTTPClient, Sendable {
    enum Response: Sendable {
        case modified(Data, CacheValidators = CacheValidators(etag: "\"v1\""))
        case notModified
        case failure(any Error & Sendable)
    }

    struct Request: Sendable {
        let url: URL
        let validators: CacheValidators?
    }

    private struct State {
        var responses: [URL: Response] = [:]
        var requests: [Request] = []
    }

    private let state = Mutex(State())

    var requests: [Request] {
        get async { state.withLock { $0.requests } }
    }

    func respond(to url: URL, with response: Response) async {
        state.withLock { $0.responses[url] = response }
    }

    func get(_ url: URL, validators: CacheValidators?) async throws -> ConditionalResponse {
        let response = state.withLock { state in
            state.requests.append(Request(url: url, validators: validators))
            return state.responses[url]
        }
        switch response {
        case .modified(let data, let validators): return .modified(data, validators)
        case .notModified: return .notModified
        case .failure(let error): throw error
        case nil: throw DocumentationError.offline
        }
    }
}
