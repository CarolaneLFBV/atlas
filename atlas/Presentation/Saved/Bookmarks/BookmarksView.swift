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
                BookmarksList(collection: collection, frameworkFilter: $frameworkFilter)
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
