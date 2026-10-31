import SwiftUI

struct FrameworkContentColumn: View {
    @State private var viewModel: DocumentationDetailViewModel

    init(viewModel: DocumentationDetailViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        content
            .navigationTitle(viewModel.entry.title)
            #if os(iOS)
            // Guide titles are long for a 320 pt column.
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .background(AtlasColor.background)
            .task { await viewModel.load() }
    }

    @ViewBuilder
    private var content: some View {
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
            let topics = fetched.value.topics
            if topics.isEmpty {
                EmptyStateView(.frameworkNoPagesTitle, systemImage: AtlasSymbol.article, message: .frameworkNoPagesMessage)
            } else {
                List {
                    Text(.frameworkPageCount(count: Set(topics.flatMap(\.entries).map(\.id)).count))
                        .font(.atlasMonoMeta)
                        .foregroundStyle(AtlasColor.secondaryText)
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                    ForEach(topics) { group in
                        Section {
                            ForEach(group.entries) { entry in
                                DocumentationLink(entry: entry) {
                                    DocumentationRow(entry: entry, showsFramework: false, showsAbstract: false)
                                }
                                .listRowBackground(Color.clear)
                            }
                        } header: {
                            Text(group.title).atlasEyebrow()
                        }
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
            }
        }
    }
}
