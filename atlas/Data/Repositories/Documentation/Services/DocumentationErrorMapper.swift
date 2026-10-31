import Foundation

nonisolated enum DocumentationErrorMapper {
    /// - Parameter id: The page concerned, used to report `notFound`.
    static func domainError(_ error: Error, for id: DocumentationID? = nil) -> DocumentationError {
        switch error {
        case let error as DocumentationError:
            return error
        case let status as HTTPStatusError where status.statusCode == 404 || status.statusCode == 410:
            return id.map(DocumentationError.notFound) ?? .invalidResponse
        default:
            return .transport(error.localizedDescription)
        }
    }
}
