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
                            card(for: entry)
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

    private func card(for entry: DocumentationEntry) -> some View {
        VStack(alignment: .leading, spacing: Spacing.s8) {
            KindTile(kind: entry.kind, frameworkName: entry.frameworkName, size: 26)
            Text(entry.title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(AtlasColor.primaryText)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
            KindTile.accessibilityName(for: entry.kind)
                .font(.atlasCaption)
                .foregroundStyle(AtlasColor.secondaryText)
        }
        .frame(width: 168, alignment: .leading)
        .frame(maxHeight: .infinity, alignment: .topLeading)
        .cardSurface(padding: Spacing.s12, fill: AtlasColor.background)
        .accessibilityElement(children: .combine)
    }
}
