import Foundation

nonisolated extension SQLiteDatabase {
    /// A `LIKE` pattern matching `text` anywhere, with wildcards in `text` escaped (use with `ESCAPE '\'`).
    static func containsPattern(_ text: String) -> String {
        "%" + likeEscaped(text) + "%"
    }

    static func placeholders(_ count: Int) -> String {
        Array(repeating: "?", count: count).joined(separator: ", ")
    }

    private static func likeEscaped(_ text: String) -> String {
        text.replacing("\\", with: "\\\\").replacing("%", with: "\\%").replacing("_", with: "\\_")
    }
}
