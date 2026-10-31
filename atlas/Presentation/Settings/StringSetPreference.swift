import Foundation

/// A set of strings stored as one `UserDefaults` string, so it works with `@AppStorage`.
nonisolated enum StringSetPreference {
    /// Newline-separated: source IDs and category names never contain newlines.
    static func decode(_ raw: String) -> Set<String> {
        Set(raw.split(separator: "\n").map(String.init))
    }

    static func encode(_ values: Set<String>) -> String {
        values.sorted().joined(separator: "\n")
    }

    static func read(_ key: String, from defaults: UserDefaults = .standard) -> Set<String> {
        decode(defaults.string(forKey: key) ?? "")
    }

    static func setting(_ value: String, included: Bool, in raw: String) -> String {
        var values = decode(raw)
        if included { values.insert(value) } else { values.remove(value) }
        return encode(values)
    }
}
