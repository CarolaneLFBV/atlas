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
                DetailPageHeader(
                    state: viewModel.state,
                    entry: viewModel.entry,
                    isFrameworkPage: isFrameworkPage,
                    reload: reload
                )
                DetailPageContent(
                    state: viewModel.state,
                    webURL: viewModel.entry.webURL,
                    isFrameworkPage: isFrameworkPage,
                    reload: reload,
                    saveSnippet: saveSnippet
                )
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
            DetailHeaderBand(
                frameworkName: viewModel.displayedEntry.frameworkName,
                title: viewModel.displayedEntry.title,
                isFrameworkPage: isFrameworkPage
            )
            .offset(y: -max(scrollOffset, 0))
        }
        .background(isFrameworkPage ? AtlasColor.background : AtlasColor.surface)
        .navigationTitle(viewModel.displayedEntry.title)
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .toolbar {
            DocumentationDetailToolbar(
                webURL: viewModel.displayedEntry.webURL,
                isBookmarked: bookmarks.isBookmarked(viewModel.displayedEntry.id),
                toggleBookmark: { bookmarks.toggle(viewModel.displayedEntry) }
            )
        }
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

    private func reload() {
        Task { await viewModel.load() }
    }

    private func saveSnippet(_ example: CodeSnippet) {
        if snippets.save(viewModel.snippetToSave(from: example)) {
            savedSnippetCount += 1
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
