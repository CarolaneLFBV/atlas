import Foundation

/// Pure and deterministic so it can be unit tested.
///
/// Scoring, highest first: exact title, title prefix, word prefix within the title
/// (so "stack" finds `NavigationStack`), title substring, keyword match, framework match.
/// Frameworks get a small boost so "swiftui" surfaces the framework before its symbols, and
/// deprecated APIs a penalty so current APIs come first.
nonisolated struct DocumentationSearchRanker: Sendable {
    func rank(_ candidates: [DocumentationEntry], for query: String, limit: Int) -> [DocumentationEntry] {
        let needle = Self.fold(query)
        guard !needle.isEmpty, limit > 0 else { return [] }

        var seen = Set<DocumentationID>()
        let scored: [(entry: DocumentationEntry, score: Int)] = candidates.compactMap { entry in
            guard seen.insert(entry.id).inserted else { return nil }
            let score = Self.score(entry, needle: needle)
            return score > 0 ? (entry, score) : nil
        }

        return scored
            .sorted { lhs, rhs in
                if lhs.score != rhs.score { return lhs.score > rhs.score }
                if lhs.entry.title.count != rhs.entry.title.count {
                    return lhs.entry.title.count < rhs.entry.title.count
                }
                return lhs.entry.title.localizedStandardCompare(rhs.entry.title) == .orderedAscending
            }
            .prefix(limit)
            .map(\.entry)
    }

    static func score(_ entry: DocumentationEntry, needle: String) -> Int {
        let title = fold(entry.title)
        var score: Int
        if title == needle {
            score = 1_000
        } else if title.hasPrefix(needle) {
            score = 800
        } else if wordStarts(in: entry.title).contains(where: { $0.hasPrefix(needle) }) {
            score = 600
        } else if title.contains(needle) {
            score = 400
        } else if entry.keywords.contains(where: { fold($0).contains(needle) }) {
            score = 200
        } else if let framework = entry.frameworkName, fold(framework).contains(needle) {
            score = 100
        } else {
            return 0
        }
        if entry.kind == .framework { score += 50 }
        // Deprecated APIs drop below current ones of similar quality; an exact title still ranks first.
        if entry.isDeprecated { score -= 150 }
        return score
    }

    static func fold(_ string: String) -> String {
        string
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .folding(options: [.caseInsensitive, .diacriticInsensitive, .widthInsensitive], locale: nil)
    }

    /// Suffixes of `title` that start at a word boundary: camel-case humps, separators, punctuation.
    /// `"NavigationStack"` → `["navigationstack", "stack"]`; `"init(_:)"` → `["init(_:)"]`.
    static func wordStarts(in title: String) -> [String] {
        let characters = Array(title)
        var starts: [String] = []
        for index in characters.indices {
            let character = characters[index]
            guard character.isLetter || character.isNumber else { continue }
            let isBoundary: Bool
            if index == characters.startIndex {
                isBoundary = true
            } else {
                let previous = characters[index - 1]
                isBoundary = !(previous.isLetter || previous.isNumber)
                    || (character.isUppercase && previous.isLowercase)
            }
            if isBoundary { starts.append(fold(String(characters[index...]))) }
        }
        return starts
    }
}
