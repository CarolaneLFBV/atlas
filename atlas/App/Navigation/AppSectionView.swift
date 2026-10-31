import SwiftUI

struct AppSectionView: View {
    let section: AppSection
    @Environment(AppDependencies.self) private var dependencies

    var body: some View {
        switch section {
        case .library:
            LibraryView(viewModel: LibraryViewModel(loadCatalogue: dependencies.loadCatalogue))
        case .search:
            SearchScreen(viewModel: SearchViewModel(searchDocumentation: dependencies.searchDocumentation))
        case .bookmarks:
            BookmarksView()
        case .snippets:
            SnippetsListView()
        case .recent:
            RecentActivityListView().navigationTitle(section.title)
        case .settings:
            SettingsView()
        }
    }
}
