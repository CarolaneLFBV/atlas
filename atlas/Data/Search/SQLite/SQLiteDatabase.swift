import Foundation
import SQLite3

/// Not thread-safe: each connection is owned by one actor, which serializes access to it.
nonisolated final class SQLiteDatabase {
    enum Location: Sendable {
        case file(URL)
        case inMemory
    }

    private let connection: OpaquePointer
    /// Prepared statements by SQL, so statements run in loops are compiled once.
    private var statements: [String: SQLiteStatement] = [:]

    init(location: Location) throws {
        let path: String
        switch location {
        case .file(let url):
            try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
            path = url.path(percentEncoded: false)
        case .inMemory:
            path = ":memory:"
        }
        var connection: OpaquePointer?
        let code = sqlite3_open_v2(path, &connection, SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE | SQLITE_OPEN_NOMUTEX, nil)
        guard code == SQLITE_OK, let connection else {
            let message = connection.map { String(cString: sqlite3_errmsg($0)) } ?? "Cannot open \(path)"
            sqlite3_close_v2(connection)
            throw SQLiteError(code: code, message: message)
        }
        self.connection = connection
        try execute("PRAGMA journal_mode = WAL; PRAGMA foreign_keys = ON;")
    }

    deinit {
        statements.removeAll()
        sqlite3_close_v2(connection)
    }

    func execute(_ sql: String) throws {
        let code = sqlite3_exec(connection, sql, nil, nil, nil)
        guard code == SQLITE_OK else {
            throw SQLiteError(code: code, message: String(cString: sqlite3_errmsg(connection)))
        }
    }

    func run(_ sql: String, _ values: [SQLiteValue] = []) throws {
        let statement = try prepared(sql)
        try statement.reset(binding: values)
        while try statement.step() {}
    }

    func query<Row>(_ sql: String, _ values: [SQLiteValue] = [], row: (SQLiteStatement) throws -> Row) throws -> [Row] {
        let statement = try prepared(sql)
        try statement.reset(binding: values)
        var rows: [Row] = []
        while try statement.step() {
            rows.append(try row(statement))
        }
        return rows
    }

    var lastInsertedRowID: Int {
        Int(sqlite3_last_insert_rowid(connection))
    }

    func transaction<Result>(_ body: () throws -> Result) throws -> Result {
        try execute("BEGIN IMMEDIATE")
        do {
            let result = try body()
            try execute("COMMIT")
            return result
        } catch {
            try? execute("ROLLBACK") // The original error is more useful than a failed rollback.
            throw error
        }
    }

    /// Creates the schema, or recreates it when `version` differs from the stored one.
    ///
    /// Only for rebuildable data (indexes): an outdated schema is dropped, not migrated.
    func prepareSchema(version: Int, tables: [String], create: String) throws {
        let current = try query("PRAGMA user_version") { $0.integer(at: 0) }.first ?? 0
        guard current != version else { return }
        try transaction {
            for table in tables {
                try execute("DROP TABLE IF EXISTS \(table)")
            }
            try execute(create)
            try execute("PRAGMA user_version = \(version)")
        }
    }

    private func prepared(_ sql: String) throws -> SQLiteStatement {
        if let statement = statements[sql] { return statement }
        let statement = try SQLiteStatement(sql: sql, connection: connection)
        statements[sql] = statement
        return statement
    }
}
