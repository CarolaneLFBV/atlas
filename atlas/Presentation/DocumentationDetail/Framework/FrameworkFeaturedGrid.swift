import SwiftUI

struct FrameworkFeaturedGrid: View {
    let entries: [DocumentationEntry]
    let frameworkName: String

    @Environment(\.openDocumentation) private var openDocumentation

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.s12) {
            SectionHeader(.frameworkFeaturedHeader)
            LazyVGrid(columns: [GridItem(.flexible(), spacing: Spacing.s12), GridItem(.flexible())], spacing: Spacing.s12) {
                ForEach(entries) { entry in
                    Button {
                        openDocumentation(entry)
                    } label: {
                        VStack(alignment: .leading, spacing: Spacing.tight) {
                            KindTile.accessibilityName(for: entry.kind)
                                .font(.system(.caption2, design: .monospaced).weight(.medium))
                                .textCase(.lowercase)
                                .foregroundStyle(FrameworkIdentity.of(frameworkName).tint)
                            Text(entry.title)
                                .font(.atlasRowTitle)
                                .foregroundStyle(AtlasColor.primaryText)
                                .lineLimit(2)
                                .multilineTextAlignment(.leading)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                        .cardSurface(padding: Spacing.s12)
                    }
                    .buttonStyle(.plain)
                    .documentationContextMenu(for: entry)
                    .accessibilityElement(children: .combine)
                }
            }
        }
    }
}
