import SwiftUI

struct SearchIdleView: View {
    @Environment(RecentActivityStore.self) private var recentActivity

    var body: some View {
        if recentActivity.items.isEmpty {
            EmptyStateView(
                .searchIdleTitle,
                systemImage: AtlasSymbol.search,
                message: .searchIdleMessage
            )
        } else {
            List {
                Section {
                    ForEach(recentActivity.items.prefix(8)) { item in
                        DocumentationLink(entry: item.entry) {
                            RecentActivityRow(item: item)
                        }
                        .listRowBackground(Color.clear)
                    }
                } header: {
                    Text(.searchRecentlyOpenedHeader).atlasEyebrow()
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
        }
    }
}
