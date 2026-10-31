import SwiftUI

struct RecentlyViewedSection: View {
    let items: [RecentActivity]
    /// Whether there is more history than shown, for "See All".
    var hasMore = false

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.inline) {
            SectionHeader(.libraryRecentlyViewedHeader) {
                if hasMore {
                    NavigationLink(.librarySeeAll) {
                        RecentActivityListView().navigationTitle(.libraryRecentlyViewedHeader)
                    }
                }
            }
            VStack(spacing: 0) {
                ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                    if index > 0 {
                        Rectangle().fill(AtlasColor.separator).frame(height: Sizing.hairline)
                            .padding(.leading, 28 + Spacing.s12)
                    }
                    DocumentationLink(entry: item.entry) {
                        RecentActivityRow(item: item)
                    }
                }
            }
        }
    }
}
