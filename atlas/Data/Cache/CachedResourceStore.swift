import Foundation
import SwiftData

/// Entries are upserted by key and never deleted on failure.
///
/// A model actor with its own context: reading and writing payloads (up to megabytes for a framework
/// index) happens off the main thread, so downloads never compete with scrolling.
@ModelActor
actor CachedResourceStore {
    func resource(forKey key: String) throws -> CachedResource? {
        try record(forKey: key).map {
            CachedResource(
                data: $0.payload,
                validators: CacheValidators(etag: $0.etag, lastModified: $0.lastModified),
                fetchedAt: $0.fetchedAt
            )
        }
    }

    func store(_ data: Data, validators: CacheValidators, forKey key: String, sourceID: DocumentationSourceID, at date: Date) throws {
        if let existing = try record(forKey: key) {
            existing.payload = data
            existing.etag = validators.etag
            existing.lastModified = validators.lastModified
            existing.fetchedAt = date
        } else {
            modelContext.insert(CachedResourceRecord(
                key: key, sourceID: sourceID.rawValue, payload: data,
                etag: validators.etag, lastModified: validators.lastModified, fetchedAt: date
            ))
        }
        try modelContext.save()
    }

    /// Marks a cached resource as confirmed current (after a `304 Not Modified`).
    func markRevalidated(key: String, at date: Date) throws {
        guard let existing = try record(forKey: key) else { return }
        existing.fetchedAt = date
        try modelContext.save()
    }

    /// When a page (not a catalogue or index) of the source was last downloaded or revalidated.
    /// Page keys are documentation storage keys (`source:/path`), so they contain `:/`.
    func lastPageFetch(for sourceID: DocumentationSourceID) throws -> Date? {
        let source = sourceID.rawValue
        var descriptor = FetchDescriptor<CachedResourceRecord>(
            predicate: #Predicate { $0.sourceID == source && $0.key.contains(":/") },
            sortBy: [SortDescriptor(\.fetchedAt, order: .reverse)]
        )
        descriptor.fetchLimit = 1
        return try modelContext.fetch(descriptor).first?.fetchedAt
    }

    private func record(forKey key: String) throws -> CachedResourceRecord? {
        var descriptor = FetchDescriptor<CachedResourceRecord>(predicate: #Predicate { $0.key == key })
        descriptor.fetchLimit = 1
        return try modelContext.fetch(descriptor).first
    }
}
