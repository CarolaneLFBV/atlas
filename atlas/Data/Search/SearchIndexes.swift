import Foundation
import OSLog

/// Both are derived data, rebuilt from the cache and from what the app reads, so an index that
/// can't be opened is deleted and recreated rather than failing the launch.
struct SearchIndexes {
    private static let logger = Logger(subsystem: "atlas", category: "SearchIndex")

    let metadata: SearchIndexStore
    let fullText: FullTextIndexStore

    static func onDisk(in directory: URL) -> SearchIndexes {
        let metadataURL = directory.appending(path: "SearchIndex.sqlite")
        let fullTextURL = directory.appending(path: "FullTextIndex.sqlite")
        return SearchIndexes(
            metadata: open(at: metadataURL) { try SearchIndexStore(location: $0) },
            fullText: open(at: fullTextURL) { try FullTextIndexStore(location: $0) }
        )
    }

    static func inMemory() -> SearchIndexes {
        do {
            return SearchIndexes(
                metadata: try SearchIndexStore(location: .inMemory),
                fullText: try FullTextIndexStore(location: .inMemory)
            )
        } catch {
            fatalError("An in-memory SQLite database must always be creatable: \(error)")
        }
    }

    /// Opens an index, deleting it once if it can't be opened, and falling back to memory as a last resort.
    private static func open<Index>(at url: URL, _ make: (SQLiteDatabase.Location) throws -> Index) -> Index {
        do {
            return try make(.file(url))
        } catch {
            logger.error("Rebuilding unreadable index \(url.lastPathComponent, privacy: .public): \(error)")
        }
        for suffix in ["", "-wal", "-shm"] {
            try? FileManager.default.removeItem(at: URL(filePath: url.path(percentEncoded: false) + suffix)) // Missing files are fine.
        }
        do {
            return try make(.file(url))
        } catch {
            logger.fault("Index \(url.lastPathComponent, privacy: .public) kept in memory: \(error)")
            do {
                return try make(.inMemory)
            } catch {
                fatalError("An in-memory SQLite database must always be creatable: \(error)")
            }
        }
    }
}
