import Foundation
import OSLog

/// Only entries the app has seen are searchable, which is why search is presented as metadata search.
///
/// Stored in SQLite, off the main thread: titles are matched through a B-tree index and other
/// metadata through an FTS5 trigram index, so substring queries stay fast over 100,000+ entries.
actor SearchIndexStore {
    private static let logger = Logger(subsystem: "atlas", category: "SearchIndex")

    /// Bump when the schema changes: the index is rebuilt from the cache rather than migrated.
    /// 2: entries stored as `StoredEntry`.
    private static let schemaVersion = 2
    private static let schema = """
        CREATE TABLE entries (
            id INTEGER PRIMARY KEY,
            key TEXT NOT NULL UNIQUE,              -- DocumentationID.storageKey
            source_id TEXT NOT NULL,
            title_text TEXT NOT NULL,              -- folded title
            payload BLOB NOT NULL,                 -- entry in the stored format (EntryPayloadCoder)
            indexed_at REAL NOT NULL
        );
        CREATE INDEX entries_title ON entries (title_text);
        -- Folded title, framework and keywords; rowid = entries.id.
        CREATE VIRTUAL TABLE entries_text USING fts5 (search_text, tokenize = 'trigram');
        -- Bulk resources (e.g. a framework's index) whose entries are in the index.
        CREATE TABLE indexed_resources (key TEXT PRIMARY KEY, indexed_at REAL NOT NULL);
        """

    private let database: SQLiteDatabase
    private let candidateLimit: Int
    private let batchSize: Int

    init(location: SQLiteDatabase.Location, candidateLimit: Int = 300, batchSize: Int = 500) throws {
        database = try SQLiteDatabase(location: location)
        try database.prepareSchema(
            version: Self.schemaVersion,
            tables: ["entries", "entries_text", "indexed_resources"],
            create: Self.schema
        )
        self.candidateLimit = candidateLimit
        self.batchSize = batchSize
    }

    /// Inserts or refreshes entries; each `DocumentationID` keeps a single record.
    ///
    /// Large lists (a framework's 30,000 symbols) are written in batches; searches run between them.
    func index(_ entries: [DocumentationEntry], at date: Date = .now) async throws {
        for start in stride(from: 0, to: entries.count, by: batchSize) {
            try Task.checkCancellation()
            let batch = entries[start..<min(start + batchSize, entries.count)]
            try database.transaction {
                for entry in batch {
                    try upsert(entry, at: date)
                }
            }
            await Task.yield()
        }
    }

    /// Candidates in priority order: exact title, title prefix, then any metadata match.
    /// Each tier is fetched separately so broad queries ("view") can't crowd out the exact page.
    func candidates(matching query: String, enabledSources: Set<DocumentationSourceID>) throws -> [DocumentationEntry] {
        let needle = DocumentationSearchRanker.fold(query)
        guard !needle.isEmpty, !enabledSources.isEmpty else { return [] }
        let sources = enabledSources.map { SQLiteValue.text($0.rawValue) }
        let inSources = "source_id IN (\(SQLiteDatabase.placeholders(sources.count)))"

        // Text compares by UTF-8 bytes, and U+10FFFF sorts after anything that may follow the prefix.
        let tiers: [(sql: String, values: [SQLiteValue])] = [
            ("SELECT key, payload FROM entries WHERE title_text = ? AND \(inSources)", [.text(needle)] + sources),
            ("SELECT key, payload FROM entries WHERE title_text >= ? AND title_text < ? AND \(inSources)",
             [.text(needle), .text(needle + "\u{10FFFF}")] + sources),
            ("""
             SELECT key, payload FROM entries_text JOIN entries ON entries.id = entries_text.rowid
             WHERE entries_text.search_text LIKE ? ESCAPE '\\' AND \(inSources)
             """, [.text(SQLiteDatabase.containsPattern(needle))] + sources),
        ]

        var seen = Set<String>()
        var payloads: [Data] = []
        for tier in tiers where payloads.count < candidateLimit {
            let rows = try database.query(tier.sql + " LIMIT ?", tier.values + [.integer(candidateLimit - payloads.count)]) {
                (key: $0.text(at: 0), payload: $0.data(at: 1))
            }
            payloads += rows.filter { seen.insert($0.key).inserted }.map(\.payload)
        }
        return payloads.compactMap(decodeEntry)
    }

    func entry(for id: DocumentationID) throws -> DocumentationEntry? {
        try database.query("SELECT payload FROM entries WHERE key = ?", [.text(id.storageKey)]) { $0.data(at: 0) }
            .first
            .flatMap(decodeEntry)
    }

    func hasIndexed(resourceKey key: String) throws -> Bool {
        try !database.query("SELECT 1 FROM indexed_resources WHERE key = ?", [.text(key)]) { _ in () }.isEmpty
    }

    func markIndexed(resourceKey key: String, at date: Date = .now) throws {
        try database.run(
            "INSERT OR REPLACE INTO indexed_resources (key, indexed_at) VALUES (?, ?)",
            [.text(key), .real(date.timeIntervalSince1970)]
        )
    }

    static func searchText(for entry: DocumentationEntry) -> String {
        ([entry.title, entry.frameworkName ?? ""] + entry.keywords)
            .map(DocumentationSearchRanker.fold)
            .joined(separator: " ")
    }

    // MARK: Writing

    private func upsert(_ entry: DocumentationEntry, at date: Date) throws {
        let key = entry.id.storageKey
        let titleText = DocumentationSearchRanker.fold(entry.title)
        let existing = try database.query("SELECT id, payload FROM entries WHERE key = ?", [.text(key)]) {
            (id: $0.integer(at: 0), payload: $0.data(at: 1))
        }.first

        guard let existing else {
            try database.run(
                "INSERT INTO entries (key, source_id, title_text, payload, indexed_at) VALUES (?, ?, ?, ?, ?)",
                [.text(key), .text(entry.id.sourceID.rawValue), .text(titleText),
                 .blob(try EntryPayloadCoder.encode(entry)), .real(date.timeIntervalSince1970)]
            )
            try database.run(
                "INSERT INTO entries_text (rowid, search_text) VALUES (?, ?)",
                [.integer(database.lastInsertedRowID), .text(Self.searchText(for: entry))]
            )
            return
        }

        let stored = decodeEntry(existing.payload)
        let merged = Self.merged(entry, into: stored)
        try database.run(
            "UPDATE entries SET title_text = ?, payload = ?, indexed_at = ? WHERE id = ?",
            [.text(titleText), .blob(try EntryPayloadCoder.encode(merged)), .real(date.timeIntervalSince1970), .integer(existing.id)]
        )
        if merged == entry {
            try database.run(
                "UPDATE entries_text SET search_text = ? WHERE rowid = ?",
                [.text(Self.searchText(for: entry)), .integer(existing.id)]
            )
        }
    }

    /// Don't let a sparse entry (e.g. from an index without abstracts) erase richer data,
    /// but always pick up a change of deprecation status.
    private static func merged(_ entry: DocumentationEntry, into stored: DocumentationEntry?) -> DocumentationEntry {
        guard let stored, entry.abstract == nil, stored.abstract != nil else { return entry }
        return DocumentationEntry(
            id: stored.id, title: stored.title, kind: stored.kind, frameworkName: stored.frameworkName,
            abstract: stored.abstract, webURL: stored.webURL, keywords: stored.keywords,
            isDeprecated: entry.isDeprecated
        )
    }

    private func decodeEntry(_ payload: Data) -> DocumentationEntry? {
        do {
            return try EntryPayloadCoder.decode(payload).entry
        } catch {
            Self.logger.error("Undecodable index entry skipped: \(error)")
            return nil
        }
    }
}
