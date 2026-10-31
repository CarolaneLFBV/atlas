import SwiftUI

struct BookmarkFilterBar: View {
    let collection: BookmarkCollection
    @Binding var selection: String?

    var body: some View {
        ScrollView(.horizontal) {
            HStack(spacing: Spacing.inline) {
                FilterChip(title: String(localized: .bookmarksFilterAll), count: collection.bookmarks.count, isSelected: selection == nil) {
                    selection = nil
                }
                ForEach(collection.frameworkNames, id: \.self) { name in
                    FilterChip(title: name, frameworkName: name, isSelected: selection == name) {
                        selection = selection == name ? nil : name
                    }
                }
            }
            .padding(.horizontal, Spacing.contentMargin)
            .padding(.vertical, Spacing.tight)
        }
        .scrollIndicators(.hidden)
        .atlasAnimation(value: selection)
    }
}
