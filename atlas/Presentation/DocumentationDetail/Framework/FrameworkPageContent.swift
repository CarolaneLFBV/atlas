import SwiftUI

/// While a query is typed, the pages matching it replace the featured symbols and topics.
struct FrameworkPageContent: View {
    let detail: DocumentationDetail

    @State private var filter = ""

    private var featured: [DocumentationEntry] {
        let symbols = detail.topics.flatMap(\.currentEntries).filter {
            if case .symbol = $0.kind { true } else { false }
        }
        return Array(symbols.prefix(4))
    }

    private var matches: [DocumentationEntry] {
        let query = filter.trimmingCharacters(in: .whitespaces)
        var seen = Set<DocumentationID>()
        return detail.topics.flatMap(\.entries).filter {
            $0.title.range(of: query, options: [.caseInsensitive, .diacriticInsensitive]) != nil && seen.insert($0.id).inserted
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.section) {
            if !detail.topics.isEmpty {
                FrameworkSearchField(frameworkName: detail.entry.title, text: $filter)
            }
            if filter.trimmingCharacters(in: .whitespaces).isEmpty {
                if featured.count >= 2 {
                    FrameworkFeaturedGrid(entries: featured, frameworkName: detail.entry.title)
                }
                if !detail.topics.isEmpty {
                    FrameworkTopicsList(topics: detail.topics)
                }
            } else {
                TopicGroupSection(group: TopicGroup(title: String(localized: .frameworkMatchingPages), entries: matches))
                if matches.isEmpty {
                    Text(.frameworkNoMatches(framework: detail.entry.title, query: filter))
                        .font(.atlasSecondary)
                        .foregroundStyle(AtlasColor.secondaryText)
                }
            }
        }
    }
}
