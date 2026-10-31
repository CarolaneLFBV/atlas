import Foundation

nonisolated struct Declaration: Hashable, Codable, Sendable {
    nonisolated struct Token: Hashable, Codable, Sendable {
        nonisolated enum Kind: String, Hashable, Codable, Sendable {
            case keyword, attribute, identifier, typeIdentifier, genericParameter
            case label, parameter, number, string, text
        }

        let kind: Kind
        let text: String
        let reference: DocumentationID?
    }

    let language: String
    let tokens: [Token]

    var source: String { tokens.map(\.text).joined() }
}
