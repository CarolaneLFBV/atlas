import SwiftUI

struct SearchResultSection: View {
    let title: LocalizedStringResource
    let results: [SearchResult]
    let query: String

    var body: some View {
        if !results.isEmpty {
            Section {
                ForEach(results) { result in
                    DocumentationLink(entry: result.entry) {
                        SearchResultRow(result: result, query: query)
                    }
                    .listRowBackground(Color.clear)
                }
            } header: {
                SearchResultSectionHeader(title: title, count: results.count)
            }
        }
    }
}
