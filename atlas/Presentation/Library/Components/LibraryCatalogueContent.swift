import SwiftUI

struct LibraryCatalogueContent: View {
    let freshness: Freshness
    let isEmpty: Bool
    let featured: [DocumentationFramework]
    let browseCategories: [DocumentationCatalogue.Category]
    let disabledSources: [DocumentationSourceStatus]
    let refresh: () -> Void

    @Environment(RecentActivityStore.self) private var recentActivity

    private let recentLimit = 5

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.screenSection) {
                LibrarySearchField()
                FreshnessNotice(freshness: freshness, retry: refresh)
                if isEmpty {
                    LibraryEmptyCatalogueView()
                } else {
                    FeaturedSection(frameworks: featured)
                    ForEach(browseCategories) { category in
                        FrameworkGrid(category: category)
                    }
                }
                if !recentActivity.items.isEmpty {
                    RecentlyViewedSection(
                        items: Array(recentActivity.items.prefix(recentLimit)),
                        hasMore: recentActivity.items.count > recentLimit
                    )
                }
                if !disabledSources.isEmpty {
                    DisabledSourcesNotice(sources: disabledSources)
                }
            }
            .padding(.horizontal, Spacing.contentMargin)
            .padding(.bottom, Spacing.s32)
            .readableWidth()
        }
    }
}
