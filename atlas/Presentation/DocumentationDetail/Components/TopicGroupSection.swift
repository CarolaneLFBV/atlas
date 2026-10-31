import SwiftUI

/// Deprecated pages are moved into a collapsed "N deprecated" group at the end: still one tap away,
/// but they don't interrupt reading the current API.
struct TopicGroupSection: View {
    let group: TopicGroup
    @State private var showsDeprecated: Bool
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    init(group: TopicGroup) {
        self.group = group
        // Collapsed when it sits beside current APIs; open when the whole group is deprecated
        // (e.g. the members of a deprecated page), so the section is never empty.
        _showsDeprecated = State(initialValue: group.currentEntries.isEmpty)
    }

    var body: some View {
        let current = group.currentEntries
        let deprecated = group.deprecatedEntries

        VStack(alignment: .leading, spacing: 0) {
            Text(group.title)
                .atlasEyebrow()
                .foregroundStyle(AtlasColor.secondaryText)
                .padding(.bottom, Spacing.s8)
                .accessibilityAddTraits(.isHeader)
            hairline
            entries(current)
            if !deprecated.isEmpty {
                DisclosureGroup(isExpanded: $showsDeprecated) {
                    entries(deprecated)
                } label: {
                    Label(.topicsDeprecatedCount(count: deprecated.count), systemImage: "archivebox")
                        .font(.atlasSecondary)
                        .foregroundStyle(AtlasColor.secondaryText)
                }
                .padding(.vertical, Spacing.inline)
                // Neutral rather than the accent color: this group shouldn't draw the eye.
                .tint(AtlasColor.secondaryText)
                .accessibilityIdentifier("topics.deprecated")
            }
        }
    }

    @ViewBuilder
    private func entries(_ entries: [DocumentationEntry]) -> some View {
        if horizontalSizeClass == .regular {
            LazyVGrid(columns: [GridItem(.flexible(), spacing: Spacing.s12), GridItem(.flexible())], spacing: Spacing.s12) {
                ForEach(entries) { entry in
                    TopicRow(entry: entry)
                        .padding(.horizontal, Spacing.s12)
                        .frame(maxHeight: .infinity, alignment: .top)
                        .cardSurface(padding: 0, fill: AtlasColor.background)
                }
            }
            .padding(.top, Spacing.s12)
        } else {
            // Lazy: some groups are long (Swift Evolution lists hundreds of proposals).
            LazyVStack(spacing: 0) {
                ForEach(entries) { entry in
                    TopicRow(entry: entry)
                    hairline
                }
            }
        }
    }

    private var hairline: some View {
        Rectangle().fill(AtlasColor.separator).frame(height: Sizing.hairline)
    }
}

#if DEBUG
#Preview {
    let entries = PreviewFixtures.entries
    let group = TopicGroup(title: "Navigation", entries: [
        entries[0],
        DocumentationEntry(id: PreviewFixtures.id("/fixtures/navigationview"), title: "NavigationView",
                           kind: .symbol(.structure), frameworkName: "SwiftUI", isDeprecated: true),
        entries[1],
    ])
    return ScrollView { TopicGroupSection(group: group).padding() }
        .previewEnvironment()
}
#endif
