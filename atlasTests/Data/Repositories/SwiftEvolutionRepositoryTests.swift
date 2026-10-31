import Foundation
import SwiftData
import Testing
@testable import atlas

@MainActor
@Suite("Swift Evolution in the repository")
struct SwiftEvolutionRepositoryTests {
    let container: ModelContainer
    let http = FakeHTTPClient()
    let indexes = SearchIndexes.inMemory()
    let source = SwiftEvolutionSource()

    init() throws {
        container = try PersistenceStore.makeContainer(inMemory: true)
    }

    private func makeRepository() -> CachedDocumentationRepository {
        CachedDocumentationRepository(
            sources: [source],
            sync: DocumentationSyncService(http: http, store: CachedResourceStore(modelContainer: container)),
            searchIndex: indexes.metadata,
            fullTextIndex: indexes.fullText
        )
    }

    private func proposalURL(_ file: String) throws -> URL {
        try #require(URL(string: "https://raw.githubusercontent.com/swiftlang/swift-evolution/main/proposals/\(file)"))
    }

    private func respond() async throws {
        await http.respond(to: try #require(source.catalogueURL), with: .modified(EvolutionFixtures.dashboard))
        for file in ["0461-async-function-isolation.md", "0467-MutableSpan.md", "0999-review.md", "0001-old.md"] {
            await http.respond(to: try proposalURL(file), with: .modified(Data(EvolutionFixtures.proposal.utf8)))
        }
    }

    @Test("Opening a proposal uses its exact, case-sensitive file URL")
    func exactFileURL() async throws {
        try await respond()
        let repository = makeRepository()

        let detail = try await repository.detail(for: DocumentationID(sourceID: source.id, path: "/proposals/0467-mutablespan"))

        #expect(detail.value.entry.title == "SE-0467: MutableSpan")
        #expect(await http.requests.contains { $0.url.lastPathComponent == "0467-MutableSpan.md" })
    }

    @Test("Offline download fetches each proposal once; a re-download with unchanged SHAs makes no proposal requests")
    func pinnedDownloads() async throws {
        try await respond()
        let repository = makeRepository()

        let first = try await repository.downloadForOffline(source.id) { _, _ in }
        let requestsAfterFirst = await http.requests.count
        let second = try await repository.downloadForOffline(source.id) { _, _ in }

        #expect(first == 4)
        #expect(second == 4)
        let proposalRequests = await http.requests.dropFirst(requestsAfterFirst).filter { $0.url.pathExtension == "md" }
        #expect(proposalRequests.isEmpty)
    }

    @Test("@concurrent finds the section named after it first")
    func fullTextSearch() async throws {
        try await respond()
        let repository = makeRepository()
        try await repository.downloadForOffline(source.id) { _, _ in }

        let results = try await SearchDocumentationUseCase(repository: repository).execute(query: "@concurrent")

        guard case .text(let section, _) = results.first?.match else {
            Issue.record("Expected a full-text match, got \(results)"); return
        }
        #expect(section == "@concurrent functions")
    }
}
