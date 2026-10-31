import SwiftUI

struct SidebarView: View {
    @Binding var selection: SidebarItem?
    let catalogue: LibraryViewModel

    @Environment(BookmarksStore.self) private var bookmarks
    @Environment(SnippetsStore.self) private var snippets
    @Environment(OfflineContentStore.self) private var offlineContent
    @AppStorage(SettingsKeys.appleContentFetchingEnabled) private var appleContentFetchingEnabled = false
    @AppStorage(SettingsKeys.turnedOffSources) private var turnedOffSources = ""
    @AppStorage(SettingsKeys.hiddenCategories) private var hiddenCategories = ""

    var body: some View {
        List(selection: $selection) {
            Section {
                brandRow
                ForEach([AppSection.library, .search]) { row(for: $0) }
                row(for: .bookmarks).badge(bookmarks.bookmarks.count)
                row(for: .snippets).badge(snippets.snippets.count)
                row(for: .recent)
            }
            let frameworks = catalogue.featured + catalogue.browseCategories.flatMap(\.frameworks)
            if !frameworks.isEmpty {
                Section {
                    ForEach(frameworks) { framework in
                        Label {
                            Text(framework.title).lineLimit(1)
                        } icon: {
                            FrameworkTile(framework.title, size: 22, style: .solid)
                        }
                        .tag(SidebarItem.framework(framework))
                    }
                } header: {
                    Text(.sidebarFrameworksHeader).atlasEyebrow()
                }
            }
            Section {
                row(for: .settings)
            }
        }
        // No navigation title: the brand row names the app.
        .safeAreaInset(edge: .bottom) { offlineFooter }
        .task(id: "\(appleContentFetchingEnabled)|\(turnedOffSources)") { await catalogue.load() }
        .onChange(of: hiddenCategories, initial: true) { _, raw in
            catalogue.hiddenCategories = StringSetPreference.decode(raw)
        }
    }

    private func row(for section: AppSection) -> some View {
        Label(section.title, systemImage: section.systemImage)
            .tag(SidebarItem.section(section))
    }

    private var brandRow: some View {
        HStack(spacing: Spacing.inline) {
            MonogramTile(text: "A", tint: AtlasColor.accent, size: 26, style: .solid)
            Text(verbatim: "Atlas").font(.headline)
        }
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isHeader)
        .selectionDisabled()
    }

    @ViewBuilder
    private var offlineFooter: some View {
        if let updated = offlineContent.statuses.compactMap(\.lastUpdated).max() {
            HStack(alignment: .firstTextBaseline, spacing: Spacing.tight) {
                Circle().fill(AtlasColor.success).frame(width: Sizing.frameworkDot, height: Sizing.frameworkDot)
                Text(.sidebarOfflineFooter(date: updated.formatted(.relative(presentation: .named))))
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)
            }
            .font(.atlasCaption)
            .foregroundStyle(AtlasColor.secondaryText)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, Spacing.s20)
            .padding(.vertical, Spacing.s12)
            .accessibilityElement(children: .combine)
        }
    }
}
