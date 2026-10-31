import SwiftUI

struct LibraryView: View {
    @State private var viewModel: LibraryViewModel
    @Environment(RecentActivityStore.self) private var recentActivity
    /// Observed so the catalogue reloads as soon as a source is turned on or off in Settings.
    @AppStorage(SettingsKeys.appleContentFetchingEnabled) private var appleContentFetchingEnabled = false
    /// Observed so the catalogue reloads when a source is turned off or back on.
    @AppStorage(SettingsKeys.turnedOffSources) private var turnedOffSources = ""
    @AppStorage(SettingsKeys.hiddenCategories) private var hiddenCategories = ""

    private let recentLimit = 5

    init(viewModel: LibraryViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        content
            .navigationTitle(.sectionLibrary)
            .task(id: "\(appleContentFetchingEnabled)|\(turnedOffSources)") { await viewModel.load() }
            .onChange(of: hiddenCategories, initial: true) { _, raw in
                viewModel.hiddenCategories = StringSetPreference.decode(raw)
            }
            .refreshable { await viewModel.refresh() }
            .background(AtlasColor.background)
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .loading:
            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.screenSection) {
                    LibrarySearchField()
                    LibraryLoadingView()
                }
                .padding(.horizontal, Spacing.contentMargin)
                .readableWidth()
            }
        case .failed(let message):
            ErrorStateView(title: .libraryErrorTitle, message: message) {
                Task { await viewModel.refresh() }
            }
        case .loaded(let fetched):
            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.screenSection) {
                    LibrarySearchField()
                    FreshnessNotice(freshness: fetched.freshness) {
                        Task { await viewModel.refresh() }
                    }
                    if fetched.value.isEmpty {
                        emptyCatalogue
                    } else {
                        FeaturedSection(frameworks: viewModel.featured)
                        ForEach(viewModel.browseCategories) { category in
                            FrameworkGrid(category: category)
                        }
                    }
                    if !recentActivity.items.isEmpty {
                        RecentlyViewedSection(
                            items: Array(recentActivity.items.prefix(recentLimit)),
                            hasMore: recentActivity.items.count > recentLimit
                        )
                    }
                    if !viewModel.disabledSources.isEmpty {
                        DisabledSourcesNotice(sources: viewModel.disabledSources)
                    }
                }
                .padding(.horizontal, Spacing.contentMargin)
                .padding(.bottom, Spacing.s32)
                .readableWidth()
            }
        }
    }

    private var emptyCatalogue: some View {
        EmptyStateView(
            .libraryEmptyTitle,
            systemImage: AtlasSymbol.library,
            message: .libraryEmptyMessage
        )
        .frame(minHeight: 320)
    }
}

#if DEBUG
#Preview("Catalogue (fixtures)") {
    NavigationStack {
        LibraryView(viewModel: LibraryViewModel(loadCatalogue: PreviewSupport.dependencies.loadCatalogue))
    }
    .previewEnvironment()
}

#Preview("No source connected") {
    NavigationStack {
        LibraryView(viewModel: LibraryViewModel(loadCatalogue: AppDependencies.inMemory().loadCatalogue))
    }
    .previewEnvironment()
}
#endif
