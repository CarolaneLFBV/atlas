import SwiftUI

struct TopicGroupPage: View {
    let group: TopicGroup

    var body: some View {
        ScrollView {
            TopicGroupSection(group: group)
                .padding(.horizontal, Spacing.contentMargin)
                .padding(.vertical, Spacing.s16)
                .readableWidth()
        }
        .background(AtlasColor.surface)
        .navigationTitle(group.title)
    }
}
