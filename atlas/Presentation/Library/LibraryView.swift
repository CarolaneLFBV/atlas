import SwiftUI

struct LibraryView: View {
    @State private var viewModel: LibraryViewModel
    /// Observed so the catalogue reloads as soon as a source is turned on or off in Settings.
    @AppStorage(SettingsKeys.appleContentFetchingEnabled) private var appleContentFetchingEnabled = false
    /// Observed so the catalogue reloads when a source is turned off or back on.
    @AppStorage(SettingsKeys.turnedOffSources) private var turnedOffSources = ""
    @AppStorage(SettingsKeys.hiddenCategories) private var hiddenCategories = ""

    init(viewModel: LibraryViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        Group {
            switch viewModel.state {
            case .loading:
                LibraryLoadingContent()
            case .failed(let message):
                ErrorStateView(title: .libraryErrorTitle, message: message, retry: refresh)
            case .loaded(let fetched):
                LibraryCatalogueContent(
                    freshness: fetched.freshness,
                    isEmpty: fetched.value.isEmpty,
                    featured: viewModel.featured,
                    browseCategories: viewModel.browseCategories,
                    disabledSources: viewModel.disabledSources,
                    refresh: refresh
                )
            }
        }
        .navigationTitle(.sectionLibrary)
        .task(id: "\(appleContentFetchingEnabled)|\(turnedOffSources)") { await viewModel.load() }
        .onChange(of: hiddenCategories, initial: true) { _, raw in
            viewModel.hiddenCategories = StringSetPreference.decode(raw)
        }
        .refreshable { await viewModel.refresh() }
        .background(AtlasColor.background)
    }

    private func refresh() {
        Task { await viewModel.refresh() }
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
