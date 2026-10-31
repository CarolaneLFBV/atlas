import Foundation
import SQLite3

/// Reused by `SQLiteDatabase`, so it's reset before every execution.
nonisolated final class SQLiteStatement {
    /// Tells SQLite to copy bound strings and blobs, since Swift may free them right after binding.
    private static let transient = unsafeBitCast(-1, to: sqlite3_destructor_type.self)

    private let handle: OpaquePointer
    private let connection: OpaquePointer

    init(sql: String, connection: OpaquePointer) throws {
        var handle: OpaquePointer?
        let code = sqlite3_prepare_v2(connection, sql, -1, &handle, nil)
        guard code == SQLITE_OK, let handle else {
            throw SQLiteError(code: code, message: String(cString: sqlite3_errmsg(connection)))
        }
        self.handle = handle
        self.connection = connection
    }

    deinit {
        sqlite3_finalize(handle)
    }

    func reset(binding values: [SQLiteValue]) throws {
        sqlite3_reset(handle)
        sqlite3_clear_bindings(handle)
        for (offset, value) in values.enumerated() {
            let index = Int32(offset + 1)
            let code: Int32 = switch value {
            case .text(let text): sqlite3_bind_text(handle, index, text, -1, Self.transient)
            case .blob(let data): data.withUnsafeBytes { sqlite3_bind_blob(handle, index, $0.baseAddress, Int32($0.count), Self.transient) }
            case .integer(let integer): sqlite3_bind_int64(handle, index, Int64(integer))
            case .real(let real): sqlite3_bind_double(handle, index, real)
            }
            try check(code)
        }
    }

    /// - Returns: `false` when there are no more rows.
    func step() throws -> Bool {
        let code = sqlite3_step(handle)
        switch code {
        case SQLITE_ROW: return true
        case SQLITE_DONE: return false
        default: throw error(code)
        }
    }

    func text(at column: Int32) -> String {
        sqlite3_column_text(handle, column).map { String(cString: $0) } ?? ""
    }

    func data(at column: Int32) -> Data {
        let count = Int(sqlite3_column_bytes(handle, column))
        guard count > 0, let bytes = sqlite3_column_blob(handle, column) else { return Data() }
        return Data(bytes: bytes, count: count)
    }

    func integer(at column: Int32) -> Int {
        Int(sqlite3_column_int64(handle, column))
    }

    private func check(_ code: Int32) throws {
        guard code == SQLITE_OK else { throw error(code) }
    }

    private func error(_ code: Int32) -> SQLiteError {
        SQLiteError(code: code, message: String(cString: sqlite3_errmsg(connection)))
    }
}
