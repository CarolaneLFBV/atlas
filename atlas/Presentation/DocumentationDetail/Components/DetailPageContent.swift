import SwiftUI

struct DetailPageContent: View {
    let state: DocumentationDetailViewModel.State
    let webURL: URL?
    let isFrameworkPage: Bool
    let reload: () -> Void
    let saveSnippet: (CodeSnippet) -> Void

    var body: some View {
        switch state {
        case .loading:
            DetailLoadingView()
        case .metadataOnly(let reason):
            OfficialDocumentationCard(url: webURL, reason: reason)
        case .failed(let message):
            ErrorStateView(title: .detailErrorTitle, message: message, retry: reload)
        case .loaded(let fetched):
            DetailLoadedContent(detail: fetched.value, isFrameworkPage: isFrameworkPage, saveSnippet: saveSnippet)
        }
    }
}
