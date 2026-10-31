import SwiftUI

struct RecentlySavedSection: View {
    let bookmarks: [Bookmark]

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.s12) {
            SectionHeader(.bookmarksRecentlySavedHeader)
            Grid(alignment: .top, horizontalSpacing: Spacing.s12) {
                GridRow {
                    ForEach(bookmarks) { bookmark in
                        RecentlySavedCard(bookmark: bookmark)
                            .frame(maxHeight: .infinity, alignment: .top)
                    }
                }
            }
        }
    }
}
