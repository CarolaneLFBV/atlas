import Foundation
import Observation

@Observable
final class SnippetsStore {
    private(set) var snippets: [CodeSnippet] = []
    private(set) var lastError: String?

    private let manageSnippets: ManageSnippetsUseCase

    init(manageSnippets: ManageSnippetsUseCase) {
        self.manageSnippets = manageSnippets
        reload()
    }

    @discardableResult
    func save(_ snippet: CodeSnippet) -> Bool {
        do {
            try manageSnippets.save(snippet)
            reload()
            return true
        } catch ValidationError.emptyField {
            lastError = String(localized: .snippetErrorEmptyCode)
            return false
        } catch {
            lastError = error.localizedDescription
            return false
        }
    }

    func delete(_ id: UUID) {
        do {
            try manageSnippets.delete(id)
            reload()
        } catch {
            lastError = error.localizedDescription
        }
    }

    func reload() {
        do {
            snippets = try manageSnippets.snippets()
            lastError = nil
        } catch {
            lastError = error.localizedDescription
        }
    }
}
