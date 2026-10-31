import SwiftUI

struct BookmarksView: View {
    @Environment(BookmarksStore.self) private var store
    @State private var frameworkFilter: String?

    private var collection: BookmarkCollection { BookmarkCollection(store.bookmarks) }

    var body: some View {
        Group {
            if store.bookmarks.isEmpty {
                BookmarksEmptyView()
            } else {
                list
            }
        }
        .navigationTitle(.sectionBookmarks)
        .background(AtlasColor.background)
        .toolbar {
            #if os(iOS)
            if !store.bookmarks.isEmpty {
                EditButton()
            }
            #endif
        }
        .onChange(of: collection.frameworkNames) { _, names in
            if let frameworkFilter, !names.contains(frameworkFilter) { self.frameworkFilter = nil }
        }
    }

    private var list: some View {
        List {
            Section {
                BookmarkFilterBar(collection: collection, selection: $frameworkFilter)
                    .listRowInsets(EdgeInsets())
                if frameworkFilter == nil, collection.bookmarks.count > 2 {
                    RecentlySavedSection(bookmarks: Array(collection.bookmarks.prefix(2)))
                        .listRowInsets(EdgeInsets(top: Spacing.s12, leading: Spacing.contentMargin, bottom: Spacing.s4, trailing: Spacing.contentMargin))
                }
            }
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)

            ForEach(collection.groups(filteredBy: frameworkFilter)) { group in
                Section {
                    ForEach(group.bookmarks) { bookmark in
                        DocumentationLink(entry: bookmark.entry) {
                            DocumentationRow(entry: bookmark.entry, showsFramework: false, showsAbstract: false)
                        }
                        .listRowBackground(Color.clear)
                    }
                    .onDelete { offsets in
                        offsets.map { group.bookmarks[$0].id }.forEach(store.remove)
                    }
                } header: {
                    BookmarkGroupHeader(frameworkName: group.frameworkName, count: group.bookmarks.count)
                }
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .accessibilityIdentifier("saved.bookmarks")
    }
}

#if DEBUG
#Preview {
    let dependencies = AppDependencies.inMemory()
    for entry in PreviewFixtures.entries { dependencies.bookmarks.toggle(entry) }
    return NavigationStack { BookmarksView() }
        .previewEnvironment(dependencies)
}

#Preview("Empty") {
    NavigationStack { BookmarksView() }
        .previewEnvironment()
}
#endif
