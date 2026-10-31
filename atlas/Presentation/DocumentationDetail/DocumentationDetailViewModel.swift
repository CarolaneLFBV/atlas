import Foundation
import Observation

@Observable
final class DocumentationDetailViewModel {
    enum State {
        case loading
        case loaded(Fetched<DocumentationDetail>)
        /// The page's content can't be shown in the app; only its metadata and official link.
        case metadataOnly(reason: String)
        case failed(String)
    }

    /// Known before loading (from the list the user tapped), so the header can render immediately.
    let entry: DocumentationEntry
    private(set) var state: State = .loading

    private let getDetail: GetDocumentationDetailUseCase

    init(entry: DocumentationEntry, getDetail: GetDocumentationDetailUseCase) {
        self.entry = entry
        self.getDetail = getDetail
    }

    var displayedEntry: DocumentationEntry {
        if case .loaded(let fetched) = state { return fetched.value.entry }
        return entry
    }

    func load() async {
        state = .loading
        do {
            state = .loaded(try await getDetail.execute(id: entry.id))
        } catch is CancellationError {
            return
        } catch let error as DocumentationError {
            switch error {
            case .sourceDisabled, .unknownSource:
                state = .metadataOnly(reason: error.userMessage)
            default:
                state = .failed(error.userMessage)
            }
        } catch {
            state = .failed(error.localizedDescription)
        }
    }

    func snippetToSave(from example: CodeSnippet) -> CodeSnippet {
        CodeSnippet(
            title: example.title.isEmpty ? displayedEntry.title : example.title,
            language: example.language,
            code: example.code,
            origin: .documentation(displayedEntry.id)
        )
    }
}
