import Foundation
import OSLog

/// One request per framework; a copy younger than the index max age isn't re-indexed, and a framework
/// is never indexed twice at once.
final class FrameworkIndexer {
    private static let logger = Logger(subsystem: "atlas", category: "FrameworkIndex")

    private let sync: DocumentationSyncService
    private let indexer: DocumentationIndexer
    private let policy: CachePolicy

    /// Keyed by framework path. Internal so tests can await completion.
    private(set) var tasks: [String: Task<Void, Never>] = [:]

    init(sync: DocumentationSyncService, indexer: DocumentationIndexer, policy: CachePolicy) {
        self.sync = sync
        self.indexer = indexer
        self.policy = policy
    }

    func startIndexing(_ framework: DocumentationEntry, from source: any DocumentationSource) {
        let path = framework.id.path
        guard tasks[path] == nil, let url = source.frameworkIndexURL(forFrameworkPath: path) else { return }

        tasks[path] = Task { [weak self] in
            guard let self else { return }
            defer { tasks[path] = nil }
            do {
                let key = "\(source.id.rawValue):framework-index:\(path)"
                let (data, freshness) = try await sync.load(url, key: key, sourceID: source.id, maxAge: policy.searchIndexMaxAge)
                // A copy within its max age needs no re-indexing, unless the index was rebuilt since.
                if case .cached = freshness, await indexer.hasIndexed(resourceKey: key) { return }
                let entries = try await SourceParser.searchEntries(from: data, source: source, frameworkName: framework.title)
                await indexer.index(entries, ofResource: key)
                Self.logger.info("Indexed \(entries.count) entries of \(framework.title, privacy: .public)")
            } catch {
                Self.logger.notice("Framework index of \(framework.title, privacy: .public) unavailable: \(error)")
            }
        }
    }
}
