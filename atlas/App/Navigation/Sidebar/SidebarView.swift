import SwiftUI

struct SidebarView: View {
    @Binding var selection: SidebarItem?
    let catalogue: LibraryViewModel

    @Environment(BookmarksStore.self) private var bookmarks
    @Environment(SnippetsStore.self) private var snippets
    @Environment(OfflineContentStore.self) private var offlineContent
    @AppStorage(SettingsKeys.appleContentFetchingEnabled) private var appleContentFetchingEnabled = false
    @AppStorage(SettingsKeys.turnedOffSources) private var turnedOffSources = ""
    @AppStorage(SettingsKeys.hiddenCategories) private var hiddenCategories = ""

    var body: some View {
        List(selection: $selection) {
            Section {
                SidebarBrandRow()
                ForEach([AppSection.library, .search]) { section in
                    SidebarSectionRow(section: section).tag(SidebarItem.section(section))
                }
                SidebarSectionRow(section: .bookmarks, badge: bookmarks.bookmarks.count)
                    .tag(SidebarItem.section(.bookmarks))
                SidebarSectionRow(section: .snippets, badge: snippets.snippets.count)
                    .tag(SidebarItem.section(.snippets))
                SidebarSectionRow(section: .recent).tag(SidebarItem.section(.recent))
            }
            let frameworks = catalogue.featured + catalogue.browseCategories.flatMap(\.frameworks)
            if !frameworks.isEmpty {
                Section {
                    ForEach(frameworks) { framework in
                        SidebarFrameworkRow(title: framework.title).tag(SidebarItem.framework(framework))
                    }
                } header: {
                    Text(.sidebarFrameworksHeader).atlasEyebrow()
                }
            }
            Section {
                SidebarSectionRow(section: .settings).tag(SidebarItem.section(.settings))
            }
        }
        // No navigation title: the brand row names the app.
        .safeAreaInset(edge: .bottom) {
            if let lastUpdated = offlineContent.statuses.compactMap(\.lastUpdated).max() {
                SidebarOfflineFooter(lastUpdated: lastUpdated)
            }
        }
        .task(id: "\(appleContentFetchingEnabled)|\(turnedOffSources)") { await catalogue.load() }
        .onChange(of: hiddenCategories, initial: true) { _, raw in
            catalogue.hiddenCategories = StringSetPreference.decode(raw)
        }
    }
}
