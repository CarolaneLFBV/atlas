import SwiftUI

/// The search field belongs to the Search tab's stack only, so it never shows up in the other tabs'
/// navigation bars; the `.search` role still places it in the tab bar.
struct CompactRootView: View {
    enum Destination: Hashable {
        case library, bookmarks, snippets, search
    }

    @State private var selection: Destination = .library
    @State private var isShowingSettings = false
    @State private var searchViewModel: SearchViewModel

    init(dependencies: AppDependencies) {
        _searchViewModel = State(initialValue: SearchViewModel(searchDocumentation: dependencies.searchDocumentation))
    }

    var body: some View {
        TabView(selection: $selection) {
            Tab(AppSection.library.title, systemImage: AppSection.library.systemImage, value: Destination.library) {
                TabNavigationStack {
                    AppSectionView(section: .library)
                        .toolbar {
                            ToolbarItem(placement: .primaryAction) {
                                Button(.librarySettingsButton, systemImage: AtlasSymbol.settings) { isShowingSettings = true }
                                    .accessibilityIdentifier("library.settings")
                            }
                        }
                }
            }
            Tab(AppSection.bookmarks.title, systemImage: AppSection.bookmarks.systemImage, value: Destination.bookmarks) {
                TabNavigationStack { AppSectionView(section: .bookmarks) }
            }
            Tab(AppSection.snippets.title, systemImage: AppSection.snippets.systemImage, value: Destination.snippets) {
                TabNavigationStack { AppSectionView(section: .snippets) }
            }
            Tab(value: Destination.search, role: .search) {
                TabNavigationStack { SearchView(viewModel: searchViewModel) }
                    .documentationSearchField(text: $searchViewModel.query, scope: $searchViewModel.scope)
            }
        }
        .tabViewSearchActivation(.searchTabSelection)
        .environment(\.showSection, ShowSectionAction { section in
            switch section {
            case .library: selection = .library
            case .bookmarks: selection = .bookmarks
            case .snippets: selection = .snippets
            case .search: selection = .search
            case .settings: isShowingSettings = true
            // History lives in the Library on iPhone.
            case .recent: selection = .library
            }
        })
        .sheet(isPresented: $isShowingSettings) {
            NavigationStack {
                SettingsView()
                    .toolbar {
                        ToolbarItem(placement: .confirmationAction) {
                            Button(.settingsDoneButton) { isShowingSettings = false }
                        }
                    }
            }
        }
    }
}
