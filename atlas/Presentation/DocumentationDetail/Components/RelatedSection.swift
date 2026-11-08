import SwiftUI

struct RelatedSection: View {
    let group: TopicGroup

    @Environment(\.openDocumentation) private var openDocumentation

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.s8) {
            Text(group.title)
                .atlasEyebrow()
                .foregroundStyle(AtlasColor.secondaryText)
                .accessibilityAddTraits(.isHeader)
            ScrollView(.horizontal) {
                LazyHStack(spacing: Spacing.s12) {
                    ForEach(group.entries) { entry in
                        Button {
                            openDocumentation(entry)
                        } label: {
                            RelatedCard(entry: entry)
                        }
                        .buttonStyle(.plain)
                        .documentationContextMenu(for: entry)
                    }
                }
            }
            .scrollIndicators(.hidden)
            .scrollClipDisabled()
        }
    }
}
