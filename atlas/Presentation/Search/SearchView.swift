import SwiftUI

/// The search field itself is provided by the container (`documentationSearchField`), so it can
/// live in the tab bar on iPhone or a column on iPad.
struct SearchView: View {
    @Bindable var viewModel: SearchViewModel
    @Environment(RecentActivityStore.self) private var recentActivity
    @AppStorage(SettingsKeys.appleContentFetchingEnabled) private var appleContentFetchingEnabled = false

    var body: some View {
        content
            .navigationTitle(.sectionSearch)
            .background(AtlasColor.background)
            .task(id: viewModel.query) { await viewModel.search() }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle:
            idleContent
        case .loading:
            LoadingStateView(title: .searchLoading)
        case .noResults(let query):
            noResults(for: query)
        case .failed(let message):
            ErrorStateView(title: .searchErrorTitle, message: message) {
                Task { await viewModel.search() }
            }
        case .results(let results):
            let groups = SearchResultGroups(results, scope: viewModel.scope)
            if groups.isEmpty {
                noResults(for: viewModel.query)
            } else {
                resultList(groups)
            }
        }
    }

    private func resultList(_ groups: SearchResultGroups) -> some View {
        List {
            if let topHit = groups.topHit {
                TopHitCard(entry: topHit.entry, query: viewModel.query)
                    .listRowInsets(EdgeInsets(top: Spacing.s16, leading: Spacing.contentMargin, bottom: Spacing.s8, trailing: Spacing.contentMargin))
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
            }
            resultSection(.searchSectionFrameworks, groups.frameworks)
            resultSection(.searchSectionSymbols, groups.symbols)
            resultSection(.searchSectionArticles, groups.articles)
            resultSection(.searchSectionPassages, groups.passages)
            Section {
                SearchScopeNotice(capability: viewModel.capability)
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .accessibilityIdentifier("search.results")
    }

    @ViewBuilder
    private func resultSection(_ title: LocalizedStringResource, _ results: [SearchResult]) -> some View {
        if !results.isEmpty {
            Section {
                ForEach(results) { result in
                    DocumentationLink(entry: result.entry) {
                        SearchResultRow(result: result, query: viewModel.query)
                    }
                    .listRowBackground(Color.clear)
                }
            } header: {
                HStack {
                    Text(title).atlasEyebrow()
                    Spacer()
                    Text(results.count, format: .number).font(.atlasMonoMeta)
                        .foregroundStyle(AtlasColor.tertiaryText)
                }
                .foregroundStyle(AtlasColor.secondaryText)
            }
        }
    }

    private func noResults(for query: String) -> some View {
        ContentUnavailableView {
            Label(.searchNoResultsTitle, systemImage: AtlasSymbol.search)
        } description: {
            if appleContentFetchingEnabled {
                Text(.searchNoResultsAppleMessage(query: query))
            } else {
                Text(.searchNoResultsMessage(query: query))
            }
        }
    }

    @ViewBuilder
    private var idleContent: some View {
        if recentActivity.items.isEmpty {
            EmptyStateView(
                .searchIdleTitle,
                systemImage: AtlasSymbol.search,
                message: .searchIdleMessage
            )
        } else {
            List {
                Section {
                    ForEach(recentActivity.items.prefix(8)) { item in
                        DocumentationLink(entry: item.entry) {
                            RecentActivityRow(item: item)
                        }
                        .listRowBackground(Color.clear)
                    }
                } header: {
                    Text(.searchRecentlyOpenedHeader).atlasEyebrow()
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
        }
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
