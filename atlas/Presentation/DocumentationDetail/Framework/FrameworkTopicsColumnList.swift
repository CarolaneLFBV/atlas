import SwiftUI

struct FrameworkTopicsColumnList: View {
    let topics: [TopicGroup]

    var body: some View {
        List {
            Text(.frameworkPageCount(count: Set(topics.flatMap(\.entries).map(\.id)).count))
                .font(.atlasMonoMeta)
                .foregroundStyle(AtlasColor.secondaryText)
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
            ForEach(topics) { group in
                Section {
                    ForEach(group.entries) { entry in
                        DocumentationLink(entry: entry) {
                            DocumentationRow(entry: entry, showsFramework: false, showsAbstract: false)
                        }
                        .listRowBackground(Color.clear)
                    }
                } header: {
                    Text(group.title).atlasEyebrow()
                }
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
    }
}
