import SwiftUI

struct FrameworkContentColumn: View {
    @State private var viewModel: DocumentationDetailViewModel

    init(viewModel: DocumentationDetailViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        Group {
            switch viewModel.state {
            case .loading:
                LoadingStateView()
            case .failed(let message):
                ErrorStateView(title: .detailErrorTitle, message: message) {
                    Task { await viewModel.load() }
                }
            case .metadataOnly(let reason):
                ScrollView {
                    OfficialDocumentationCard(url: viewModel.entry.webURL, reason: reason).padding()
                }
            case .loaded(let fetched):
                if fetched.value.topics.isEmpty {
                    EmptyStateView(.frameworkNoPagesTitle, systemImage: AtlasSymbol.article, message: .frameworkNoPagesMessage)
                } else {
                    FrameworkTopicsColumnList(topics: fetched.value.topics)
                }
            }
        }
        .navigationTitle(viewModel.entry.title)
        #if os(iOS)
        // Guide titles are long for a 320 pt column.
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .background(AtlasColor.background)
        .task { await viewModel.load() }
    }
}
