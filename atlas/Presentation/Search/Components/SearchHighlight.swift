import SwiftUI

/// Marks every occurrence of a query in a text (case- and diacritic-insensitive) with the
/// handoff's highlight: accent at 14% behind the match.
enum SearchHighlight {
    static func highlighted(_ text: String, query: String, emphasizes: Bool = false) -> AttributedString {
        var attributed = AttributedString(text)
        let needle = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !needle.isEmpty else { return attributed }
        var searchStart = text.startIndex
        while let range = text.range(of: needle, options: [.caseInsensitive, .diacriticInsensitive], range: searchStart..<text.endIndex) {
            if let attributedRange = Range(range, in: attributed) {
                attributed[attributedRange].backgroundColor = AtlasColor.accent.opacity(0.14)
                if emphasizes {
                    attributed[attributedRange].foregroundColor = AtlasColor.primaryText
                }
            }
            searchStart = range.upperBound
        }
        return attributed
    }
}
