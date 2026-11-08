import SwiftUI

struct DetailTopicsSection: View {
    let topics: [TopicGroup]

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.s24) {
            DetailSectionTitle(.detailTopicsTitle)
            ForEach(topics) { TopicGroupSection(group: $0) }
        }
    }
}
