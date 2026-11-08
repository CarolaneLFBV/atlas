import SwiftUI

struct BookmarksList: View {
    let collection: BookmarkCollection
    @Binding var frameworkFilter: String?

    @Environment(BookmarksStore.self) private var store

    var body: some View {
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
