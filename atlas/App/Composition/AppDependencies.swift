import Foundation
import SwiftData
import SwiftUI

/// Views receive this through the environment and pass use cases to their view models'
/// initializers, so every feature stays testable with substitute repositories.
@Observable
final class AppDependencies {
    let modelContainer: ModelContainer

    let documentationRepository: any DocumentationRepository
    let bookmarkRepository: any BookmarkRepository
    let snippetRepository: any SnippetRepository
    let activityRepository: any RecentActivityRepository

    let bookmarks: BookmarksStore
    let snippets: SnippetsStore
    let recentActivity: RecentActivityStore
    let offlineContent: OfflineContentStore

    /// - Parameter documentationRepository: Builds the documentation repository from the store's container
    ///   (its cache works on a background context of its own).
    init(
        modelContainer: ModelContainer,
        documentationRepository makeDocumentationRepository: (ModelContainer) -> any DocumentationRepository
    ) {
        self.modelContainer = modelContainer

        let context = modelContainer.mainContext
        documentationRepository = makeDocumentationRepository(modelContainer)
        let bookmarkRepository = SwiftDataBookmarkRepository(context: context)
        let snippetRepository = SwiftDataSnippetRepository(context: context)
        let activityRepository = SwiftDataRecentActivityRepository(context: context)
        self.bookmarkRepository = bookmarkRepository
        self.snippetRepository = snippetRepository
        self.activityRepository = activityRepository

        bookmarks = BookmarksStore(
            toggleBookmark: ToggleBookmarkUseCase(repository: bookmarkRepository),
            manageBookmarks: ManageBookmarksUseCase(repository: bookmarkRepository)
        )
        snippets = SnippetsStore(manageSnippets: ManageSnippetsUseCase(repository: snippetRepository))
        recentActivity = RecentActivityStore(manageActivity: ManageRecentActivityUseCase(repository: activityRepository))
        offlineContent = OfflineContentStore(
            downloadContent: (documentationRepository as? any OfflineContentRepository).map(DownloadOfflineContentUseCase.init)
        )
    }

    /// In catalogue order.
    static func liveSources() -> [any DocumentationSource] {
        [
            OpenDocCArchiveSource.swiftBook,
            OpenDocCArchiveSource.swiftMigrationGuide,
            SwiftEvolutionSource(),
            AppleDeveloperDocumentationSource(isEnabled: {
                UserDefaults.standard.bool(forKey: SettingsKeys.appleContentFetchingEnabled)
            }),
        ]
    }

    static func cachedRepository(
        sources: [any DocumentationSource],
        http: any HTTPClient = URLSessionHTTPClient(),
        indexes: @escaping () -> SearchIndexes = { .inMemory() },
        isTurnedOffByUser: @escaping @Sendable (DocumentationSourceID) -> Bool = { _ in false }
    ) -> (ModelContainer) -> any DocumentationRepository {
        { container in
            let indexes = indexes()
            return CachedDocumentationRepository(
                sources: sources,
                sync: DocumentationSyncService(http: http, store: CachedResourceStore(modelContainer: container)),
                searchIndex: indexes.metadata,
                fullTextIndex: indexes.fullText,
                isTurnedOffByUser: isTurnedOffByUser
            )
        }
    }

    static func live() throws -> AppDependencies {
        AppDependencies(
            modelContainer: try PersistenceStore.makeContainer(),
            documentationRepository: cachedRepository(
                sources: liveSources(),
                indexes: { .onDisk(in: .applicationSupportDirectory.appending(path: "SearchIndexes")) },
                isTurnedOffByUser: { StringSetPreference.read(SettingsKeys.turnedOffSources).contains($0.rawValue) }
            )
        )
    }

    /// With no repository given, no source is configured and nothing touches the network.
    static func inMemory(documentationRepository: (any DocumentationRepository)? = nil) -> AppDependencies {
        do {
            return AppDependencies(
                modelContainer: try PersistenceStore.makeContainer(inMemory: true),
                documentationRepository: { container in
                    documentationRepository ?? cachedRepository(sources: [])(container)
                }
            )
        } catch {
            fatalError("An in-memory SwiftData store must always be creatable: \(error)")
        }
    }

    // MARK: Use cases

    var loadCatalogue: LoadCatalogueUseCase { LoadCatalogueUseCase(repository: documentationRepository) }
    var searchDocumentation: SearchDocumentationUseCase { SearchDocumentationUseCase(repository: documentationRepository) }
    var getDocumentationDetail: GetDocumentationDetailUseCase {
        GetDocumentationDetailUseCase(repository: documentationRepository, activity: activityRepository)
    }
}

extension View {
    func appDependencies(_ dependencies: AppDependencies) -> some View {
        self
            .environment(dependencies)
            .environment(dependencies.bookmarks)
            .environment(dependencies.snippets)
            .environment(dependencies.recentActivity)
            .environment(dependencies.offlineContent)
            .modelContainer(dependencies.modelContainer)
    }
}
