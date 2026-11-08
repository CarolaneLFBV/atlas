import SwiftUI

/// The search field itself is provided by the container (`documentationSearchField`), so it can
/// live in the tab bar on iPhone or a column on iPad.
struct SearchView: View {
    @Bindable var viewModel: SearchViewModel

    var body: some View {
        Group {
            switch viewModel.state {
            case .idle:
                SearchIdleView()
            case .loading:
                LoadingStateView(title: .searchLoading)
            case .noResults(let query):
                SearchNoResultsView(query: query)
            case .failed(let message):
                ErrorStateView(title: .searchErrorTitle, message: message) {
                    Task { await viewModel.search() }
                }
            case .results(let results):
                let groups = SearchResultGroups(results, scope: viewModel.scope)
                if groups.isEmpty {
                    SearchNoResultsView(query: viewModel.query)
                } else {
                    SearchResultList(groups: groups, query: viewModel.query, capability: viewModel.capability)
                }
            }
        }
        .navigationTitle(.sectionSearch)
        .background(AtlasColor.background)
        .task(id: viewModel.query) { await viewModel.search() }
    }
}

#if DEBUG
#Preview {
    NavigationStack {
        SearchScreen(viewModel: SearchViewModel(searchDocumentation: PreviewSupport.dependencies.searchDocumentation))
    }
    .previewEnvironment()
}
#endif
