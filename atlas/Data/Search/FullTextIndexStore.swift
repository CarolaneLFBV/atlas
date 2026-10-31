import Foundation
import OSLog

/// Stored in SQLite, off the main thread, with an FTS5 trigram index so substring queries
/// ("@concurrent") don't scan every passage.
actor FullTextIndexStore {
    private static let logger = Logger(subsystem: "atlas", category: "FullTextIndex")

    /// Bump when the schema changes: the index is rebuilt from the cache rather than migrated.
    /// 2: entries stored as `StoredEntry`.
    private static let schemaVersion = 2
    private static let schema = """
        CREATE TABLE pages (
            key TEXT PRIMARY KEY,                  -- DocumentationID.storageKey
            source_id TEXT NOT NULL,
            payload BLOB NOT NULL                  -- entry in the stored format (EntryPayloadCoder)
        );
        CREATE INDEX pages_source ON pages (source_id);
        CREATE TABLE passages (
            id INTEGER PRIMARY KEY,
            page_key TEXT NOT NULL REFERENCES pages (key) ON DELETE CASCADE,
            section_title TEXT NOT NULL,
            position INTEGER NOT NULL,
            text TEXT NOT NULL                     -- original text, for excerpts
        );
        CREATE INDEX passages_page ON passages (page_key, position);
        -- Folded section title and text; rowid = passages.id.
        CREATE VIRTUAL TABLE passages_text USING fts5 (title_text, body_text, tokenize = 'trigram');
        """

    private let database: SQLiteDatabase
    private let resultLimit: Int

    init(location: SQLiteDatabase.Location, resultLimit: Int = 40) throws {
        database = try SQLiteDatabase(location: location)
        try database.prepareSchema(
            version: Self.schemaVersion,
            tables: ["passages_text", "passages", "pages"],
            create: Self.schema
        )
        self.resultLimit = resultLimit
    }

    /// Replaces the indexed text of a page with its current passages, so the index never keeps
    /// text that no longer exists in the source.
    func replacePassages(of entry: DocumentationEntry, with passages: [FullTextExtractor.Passage]) throws {
        let pageKey = entry.id.storageKey
        let payload = try EntryPayloadCoder.encode(entry)
        try database.transaction {
            try database.run(
                "DELETE FROM passages_text WHERE rowid IN (SELECT id FROM passages WHERE page_key = ?)",
                [.text(pageKey)]
            )
            try database.run("DELETE FROM pages WHERE key = ?", [.text(pageKey)])
            guard !passages.isEmpty else { return }

            try database.run(
                "INSERT INTO pages (key, source_id, payload) VALUES (?, ?, ?)",
                [.text(pageKey), .text(entry.id.sourceID.rawValue), .blob(payload)]
            )
            for (position, passage) in passages.enumerated() {
                try database.run(
                    "INSERT INTO passages (page_key, section_title, position, text) VALUES (?, ?, ?, ?)",
                    [.text(pageKey), .text(passage.title), .integer(position), .text(passage.text)]
                )
                try database.run(
                    "INSERT INTO passages_text (rowid, title_text, body_text) VALUES (?, ?, ?)",
                    [.integer(database.lastInsertedRowID),
                     .text(DocumentationSearchRanker.fold(passage.title)),
                     .text(DocumentationSearchRanker.fold(passage.text))]
                )
            }
        }
    }

    /// Passages containing `query`, in page and reading order, with an excerpt around the match.
    func matches(for query: String, enabledSources: Set<DocumentationSourceID>) throws -> [FullTextMatch] {
        let needle = DocumentationSearchRanker.fold(query)
        guard !needle.isEmpty, !enabledSources.isEmpty else { return [] }
        let sources = enabledSources.map { SQLiteValue.text($0.rawValue) }
        let pattern = SQLiteValue.text(SQLiteDatabase.containsPattern(needle))

        // Passages whose heading names the query ("@concurrent functions") come before passing mentions.
        // Each tier is fetched separately so the result limit can't drop the best passages.
        var seen = Set<Int>()
        var matches: [FullTextMatch] = []
        for column in ["title_text", "body_text"] where matches.count < resultLimit {
            let sql = """
                SELECT passages.id, passages.section_title, passages.text, pages.payload
                FROM passages_text
                JOIN passages ON passages.id = passages_text.rowid
                JOIN pages ON pages.key = passages.page_key
                WHERE passages_text.\(column) LIKE ? ESCAPE '\\'
                  AND pages.source_id IN (\(SQLiteDatabase.placeholders(sources.count)))
                ORDER BY passages.page_key DESC, passages.position
                LIMIT ?
                """
            let rows = try database.query(sql, [pattern] + sources + [.integer(resultLimit - matches.count)]) {
                (id: $0.integer(at: 0), sectionTitle: $0.text(at: 1), text: $0.text(at: 2), payload: $0.data(at: 3))
            }
            for row in rows where seen.insert(row.id).inserted {
                guard let entry = decodeEntry(row.payload) else { continue }
                matches.append(FullTextMatch(
                    entry: entry,
                    sectionTitle: row.sectionTitle,
                    excerpt: Self.excerpt(of: row.text, around: query)
                ))
            }
        }
        return matches
    }

    func pageCount(for sourceID: DocumentationSourceID) throws -> Int {
        try database.query("SELECT COUNT(*) FROM pages WHERE source_id = ?", [.text(sourceID.rawValue)]) {
            $0.integer(at: 0)
        }.first ?? 0
    }

    /// About `radius` characters on each side of the first occurrence, cut at word boundaries.
    static func excerpt(of text: String, around query: String, radius: Int = 70) -> String {
        let flattened = text.replacingOccurrences(of: "\n", with: " ")
        guard let range = flattened.range(of: query, options: [.caseInsensitive, .diacriticInsensitive]) else {
            return String(flattened.prefix(radius * 2))
        }
        var start = flattened.index(range.lowerBound, offsetBy: -radius, limitedBy: flattened.startIndex) ?? flattened.startIndex
        var end = flattened.index(range.upperBound, offsetBy: radius, limitedBy: flattened.endIndex) ?? flattened.endIndex
        if start > flattened.startIndex, let space = flattened[start..<range.lowerBound].firstIndex(of: " ") {
            start = flattened.index(after: space)
        }
        if end < flattened.endIndex, let space = flattened[range.upperBound..<end].lastIndex(of: " ") {
            end = space
        }
        let prefix = start > flattened.startIndex ? "…" : ""
        let suffix = end < flattened.endIndex ? "…" : ""
        return prefix + flattened[start..<end].trimmingCharacters(in: .whitespaces) + suffix
    }

    private func decodeEntry(_ payload: Data) -> DocumentationEntry? {
        do {
            return try EntryPayloadCoder.decode(payload).entry
        } catch {
            Self.logger.error("Undecodable full-text page skipped: \(error)")
            return nil
        }
    }
}
