import SwiftUI

struct DocumentationDetailView: View {
    @State private var viewModel: DocumentationDetailViewModel
    @State private var savedSnippetCount = 0
    /// How far the page is scrolled, so the header band scrolls away with the content.
    @State private var scrollOffset: CGFloat = 0

    @Environment(BookmarksStore.self) private var bookmarks
    @Environment(SnippetsStore.self) private var snippets
    @Environment(RecentActivityStore.self) private var recentActivity
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.openDocumentation) private var openDocumentation

    init(viewModel: DocumentationDetailViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    /// Framework pages get the hero header and topic list of the handoff's framework screen.
    /// Decided by the entry that was opened (catalogue entries are frameworks), since the loaded page
    /// of a guide's root is a DocC collection.
    private var isFrameworkPage: Bool {
        viewModel.entry.kind == .framework || viewModel.displayedEntry.kind == .framework
    }

    private var margin: CGFloat {
        horizontalSizeClass == .regular ? Spacing.readingMargin : Spacing.contentMargin
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.section) {
                header
                content
            }
            .padding(.horizontal, margin)
            .padding(.top, Spacing.s8)
            .padding(.bottom, Spacing.s40)
            .readableWidth()
        }
        .onScrollGeometryChange(for: CGFloat.self) { geometry in
            geometry.contentOffset.y + geometry.contentInsets.top
        } action: { _, offset in
            scrollOffset = offset
        }
        .background(alignment: .top) {
            // Pulled up as the page scrolls; pulling down past the top doesn't detach it.
            headerBackground.offset(y: -max(scrollOffset, 0))
        }
        .background(isFrameworkPage ? AtlasColor.background : AtlasColor.surface)
        .navigationTitle(viewModel.displayedEntry.title)
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .toolbar { toolbarContent }
        .task {
            await viewModel.load()
            recentActivity.reload()
        }
        .sensoryFeedback(.success, trigger: savedSnippetCount)
        .environment(\.openURL, OpenURLAction(handler: openReference))
    }

    /// Opens references tapped in prose inside the app; other links go to the browser.
    private func openReference(_ url: URL) -> OpenURLAction.Result {
        guard let reference = DocumentationReferenceURL.entry(from: url) else { return .systemAction }
        // Prefer the page's own copy of the entry (kind, framework, abstract) when it lists it.
        openDocumentation(knownEntry(for: reference.id) ?? reference)
        return .handled
    }

    private func knownEntry(for id: DocumentationID) -> DocumentationEntry? {
        guard case .loaded(let fetched) = viewModel.state else { return nil }
        let detail = fetched.value
        return ((detail.topics + detail.relationships).flatMap(\.entries) + detail.replacements).first { $0.id == id }
    }

    // MARK: Sections

    /// The band of the framework's color, drawn behind the scroll view so it reaches the top of the
    /// screen under the navigation bar, and moved with the scroll offset so it stays at the top of the
    /// page. Only the band ignores the safe area; the content doesn't.
    @ViewBuilder
    private var headerBackground: some View {
        Group {
            if isFrameworkPage {
                DetailHeaderBackground(
                    frameworkName: viewModel.displayedEntry.frameworkName ?? viewModel.displayedEntry.title,
                    strength: 0.16, height: 460, planeWidth: 150, showsFullPlanes: true
                )
            } else {
                DetailHeaderBackground(frameworkName: viewModel.displayedEntry.frameworkName)
            }
        }
        .ignoresSafeArea(edges: .top)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: Spacing.s16) {
            if case .loaded(let fetched) = viewModel.state {
                FreshnessNotice(freshness: fetched.freshness) {
                    Task { await viewModel.load() }
                }
                if isFrameworkPage {
                    FrameworkHeaderView(detail: fetched.value)
                } else {
                    DetailHeaderView(entry: fetched.value.entry, isDeprecated: fetched.value.isDeprecated)
                }
                if !isFrameworkPage, !fetched.value.availability.isEmpty {
                    AvailabilityView(availability: fetched.value.availability, frameworkName: fetched.value.entry.frameworkName)
                }
            } else {
                DetailHeaderView(entry: viewModel.entry)
            }
        }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .loading:
            DetailLoadingView()
        case .metadataOnly(let reason):
            OfficialDocumentationCard(url: viewModel.entry.webURL, reason: reason)
        case .failed(let message):
            ErrorStateView(title: .detailErrorTitle, message: message) {
                Task { await viewModel.load() }
            }
        case .loaded(let fetched):
            loaded(fetched.value)
        }
    }

    @ViewBuilder
    private func loaded(_ detail: DocumentationDetail) -> some View {
        if detail.isDeprecated {
            DeprecationBanner(notice: detail.deprecationNotice, replacements: detail.replacements)
        }
        if let declaration = detail.declaration {
            DeclarationView(declaration: declaration)
        }
        if isFrameworkPage {
            FrameworkPageContent(detail: detail)
        }
        if detail.permission.allowsProse {
            ForEach(detail.sections) { section in
                VStack(alignment: .leading, spacing: Spacing.s16) {
                    DetailSectionTitle(section.title)
                    ForEach(Array(section.blocks.enumerated()), id: \.offset) { _, block in
                        ContentBlockView(block: block, saveSnippet: saveSnippet, frameworkName: detail.entry.frameworkName)
                    }
                }
            }
        } else {
            OfficialDocumentationCard(
                url: detail.entry.webURL,
                reason: String(localized: .detailFullTextOnWebsite)
            )
        }
        if !isFrameworkPage, !detail.topics.isEmpty {
            VStack(alignment: .leading, spacing: Spacing.s24) {
                DetailSectionTitle(.detailTopicsTitle)
                ForEach(detail.topics) { TopicGroupSection(group: $0) }
            }
        }
        if !detail.relationships.isEmpty {
            VStack(alignment: .leading, spacing: Spacing.s16) {
                DetailSectionTitle(.detailRelatedTitle)
                ForEach(detail.relationships) { RelatedSection(group: $0) }
            }
        }
        LicenseFooter(permission: detail.permission, webURL: detail.entry.webURL)
    }

    private func saveSnippet(_ example: CodeSnippet) {
        if snippets.save(viewModel.snippetToSave(from: example)) {
            savedSnippetCount += 1
        }
    }

    // MARK: Toolbar

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        let entry = viewModel.displayedEntry
        ToolbarItemGroup(placement: .primaryAction) {
            if let url = entry.webURL {
                ShareLink(item: url)
            }
            BookmarkButton(isBookmarked: bookmarks.isBookmarked(entry.id)) {
                bookmarks.toggle(entry)
            }
            .keyboardShortcut("d", modifiers: .command)
        }
        if let url = entry.webURL {
            ToolbarItem(placement: .secondaryAction) {
                Link(destination: url) {
                    Label(.contextMenuOpenOnWeb, systemImage: AtlasSymbol.openExternal)
                }
            }
        }
    }
}

#if DEBUG
#Preview("Full content (fixtures)") {
    NavigationStack {
        DocumentationDetailView(viewModel: DocumentationDetailViewModel(
            entry: PreviewFixtures.entries[0],
            getDetail: PreviewSupport.dependencies.getDocumentationDetail
        ))
    }
    .previewEnvironment()
}

#Preview("Metadata only") {
    let dependencies = AppDependencies.inMemory()
    NavigationStack {
        DocumentationDetailView(viewModel: DocumentationDetailViewModel(
            entry: PreviewFixtures.entries[0],
            getDetail: dependencies.getDocumentationDetail
        ))
    }
    .previewEnvironment(dependencies)
}
#endif
