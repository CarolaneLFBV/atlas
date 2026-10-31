import Foundation

nonisolated struct URLSessionHTTPClient: HTTPClient {
    private let session: URLSession
    private let userAgent: String

    init(session: URLSession = .shared, userAgent: String = "Atlas/1.0 (documentation companion)") {
        self.session = session
        self.userAgent = userAgent
    }

    func get(_ url: URL, validators: CacheValidators?) async throws -> ConditionalResponse {
        let request = makeRequest(for: url, validators: validators)

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await session.data(for: request)
        } catch let error as URLError {
            throw Self.map(error)
        }

        guard let http = response as? HTTPURLResponse else { throw DocumentationError.invalidResponse }
        switch http.statusCode {
        case 200..<300:
            let newValidators = CacheValidators(
                etag: http.value(forHTTPHeaderField: "ETag"),
                lastModified: http.value(forHTTPHeaderField: "Last-Modified")
            )
            return .modified(data, newValidators)
        case 304:
            return .notModified
        case 404, 410:
            throw HTTPStatusError(statusCode: http.statusCode)
        default:
            throw DocumentationError.transport(HTTPURLResponse.localizedString(forStatusCode: http.statusCode))
        }
    }

    private func makeRequest(for url: URL, validators: CacheValidators?) -> URLRequest {
        var request = URLRequest(url: url)
        // The app keeps its own cache with explicit validators, so bypass URLCache to avoid double caching.
        request.cachePolicy = .reloadIgnoringLocalCacheData
        request.setValue(userAgent, forHTTPHeaderField: "User-Agent")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        if let etag = validators?.etag {
            request.setValue(etag, forHTTPHeaderField: "If-None-Match")
        }
        if let lastModified = validators?.lastModified {
            request.setValue(lastModified, forHTTPHeaderField: "If-Modified-Since")
        }
        return request
    }

    private static func map(_ error: URLError) -> Error {
        switch error.code {
        case .notConnectedToInternet, .networkConnectionLost, .dataNotAllowed,
             .internationalRoamingOff, .cannotFindHost, .cannotConnectToHost, .timedOut:
            DocumentationError.offline
        case .cancelled:
            CancellationError()
        default:
            DocumentationError.transport(error.localizedDescription)
        }
    }
}
