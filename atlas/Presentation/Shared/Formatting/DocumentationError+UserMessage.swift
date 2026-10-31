import Foundation

extension DocumentationError {
    var userMessage: String {
        switch self {
        case .offline:
            String(localized: .errorOffline)
        case .notFound:
            String(localized: .errorNotFound)
        case .sourceDisabled:
            String(localized: .errorSourceDisabled)
        case .unknownSource:
            String(localized: .errorUnknownSource)
        case .invalidResponse:
            String(localized: .errorInvalidResponse)
        case .transport(let reason):
            String(localized: .errorTransport(reason: reason))
        }
    }
}

extension Error {
    var documentationUserMessage: String {
        (self as? DocumentationError)?.userMessage ?? localizedDescription
    }
}
