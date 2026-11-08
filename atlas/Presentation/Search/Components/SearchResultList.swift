import SwiftUI

struct SearchResultList: View {
    let groups: SearchResultGroups
    let query: String
    let capability: SearchCapability

    var body: some View {
        List {
            if let topHit = groups.topHit {
                TopHitCard(entry: topHit.entry, query: query)
                    .listRowInsets(EdgeInsets(top: Spacing.s16, leading: Spacing.contentMargin, bottom: Spacing.s8, trailing: Spacing.contentMargin))
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
            }
            SearchResultSection(title: .searchSectionFrameworks, results: groups.frameworks, query: query)
            SearchResultSection(title: .searchSectionSymbols, results: groups.symbols, query: query)
            SearchResultSection(title: .searchSectionArticles, results: groups.articles, query: query)
            SearchResultSection(title: .searchSectionPassages, results: groups.passages, query: query)
            Section {
                SearchScopeNotice(capability: capability)
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .accessibilityIdentifier("search.results")
    }
}
