import Foundation
import OSLog

/// Indexing is best effort: a failure is logged and never prevents reading a page.
final class DocumentationIndexer {
    private static let logger = Logger(subsystem: "atlas", category: "Indexing")

    let searchIndex: SearchIndexStore
    let fullTextIndex: FullTextIndexStore

    init(searchIndex: SearchIndexStore, fullTextIndex: FullTextIndexStore) {
        self.searchIndex = searchIndex
        self.fullTextIndex = fullTextIndex
    }

    /// Large lists are written in batches.
    func index(_ entries: [DocumentationEntry]) async {
        do {
            try await searchIndex.index(entries)
        } catch is CancellationError {
            return
        } catch {
            Self.logger.error("Metadata indexing of \(entries.count) entries failed: \(error)")
        }
    }

    func index(_ detail: DocumentationDetail, from source: any DocumentationSource) async {
        await index([detail.entry] + (detail.topics + detail.relationships).flatMap(\.entries))
        guard source.allowsOfflineDownload, detail.permission.allowsProse else { return }
        do {
            try await fullTextIndex.replacePassages(of: detail.entry, with: FullTextExtractor.passages(from: detail))
        } catch {
            Self.logger.error("Full-text indexing of \(detail.entry.id.storageKey, privacy: .public) failed: \(error)")
        }
    }

    func knownEntry(for id: DocumentationID) async -> DocumentationEntry? {
        do {
            return try await searchIndex.entry(for: id)
        } catch {
            Self.logger.error("Index lookup of \(id.storageKey, privacy: .public) failed: \(error)")
            return nil
        }
    }

    /// `false` if the index can't be read.
    func hasIndexed(resourceKey key: String) async -> Bool {
        do {
            return try await searchIndex.hasIndexed(resourceKey: key)
        } catch {
            Self.logger.error("Index lookup of \(key, privacy: .public) failed: \(error)")
            return false
        }
    }

    func index(_ entries: [DocumentationEntry], ofResource key: String) async {
        do {
            try await searchIndex.index(entries)
            try await searchIndex.markIndexed(resourceKey: key)
        } catch is CancellationError {
            return
        } catch {
            Self.logger.error("Indexing \(key, privacy: .public) failed: \(error)")
        }
    }

    /// 0 if the index can't be read.
    func fullTextPageCount(for sourceID: DocumentationSourceID) async -> Int {
        do {
            return try await fullTextIndex.pageCount(for: sourceID)
        } catch {
            Self.logger.error("Full-text page count of \(sourceID.rawValue, privacy: .public) failed: \(error)")
            return 0
        }
    }
}
