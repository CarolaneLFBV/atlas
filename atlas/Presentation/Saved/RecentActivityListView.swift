import SwiftUI

struct RecentActivityListView: View {
    @Environment(RecentActivityStore.self) private var recentActivity

    var body: some View {
        if recentActivity.items.isEmpty {
            EmptyStateView(
                .recentEmptyTitle,
                systemImage: AtlasSymbol.recent,
                message: .recentEmptyMessage
            )
        } else {
            List {
                ForEach(recentActivity.items) { item in
                    DocumentationLink(entry: item.entry) {
                        RecentActivityRow(item: item)
                    }
                }
            }
        }
    }
}
