import Foundation

nonisolated struct DeclarationDTO: Decodable, Sendable {
    nonisolated struct Token: Decodable, Sendable {
        let kind: String?
        let text: String
        /// DocC reference URI for linkable type identifiers.
        let identifier: String?
    }

    let languages: [String]?
    let tokens: [Token]?
}
