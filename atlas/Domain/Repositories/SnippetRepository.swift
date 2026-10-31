import Foundation

protocol SnippetRepository: AnyObject {
    func snippets() throws -> [CodeSnippet]
    /// Inserts a new snippet or updates the existing one with the same `id`.
    func save(_ snippet: CodeSnippet) throws
    func deleteSnippet(_ id: UUID) throws
}
