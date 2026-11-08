import SwiftUI

struct FrameworkTopicsList: View {
    let topics: [TopicGroup]

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.s8) {
            SectionHeader(.detailTopicsTitle)
            VStack(spacing: 0) {
                ForEach(topics) { group in
                    NavigationLink {
                        TopicGroupPage(group: group)
                    } label: {
                        HStack(spacing: Spacing.inline) {
                            Text(group.title)
                                .font(.callout.weight(.medium))
                                .foregroundStyle(AtlasColor.primaryText)
                                .multilineTextAlignment(.leading)
                            Spacer()
                            Text(group.entries.count, format: .number)
                                .font(.atlasMonoMeta)
                                .foregroundStyle(AtlasColor.secondaryText)
                            Image(systemName: AtlasSymbol.disclosure)
                                .font(.footnote.weight(.semibold))
                                .foregroundStyle(AtlasColor.tertiaryText)
                                .accessibilityHidden(true)
                        }
                        .frame(minHeight: 46)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    HairlineDivider()
                }
            }
        }
    }
}
