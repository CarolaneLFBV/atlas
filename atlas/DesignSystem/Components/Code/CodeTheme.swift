import SwiftUI

enum CodeTheme {
    static func color(for kind: CodeTokenizer.Kind) -> Color {
        switch kind {
        case .plain: AtlasColor.primaryText
        // Attributes (`@MainActor`) share the keyword color, as in Xcode.
        case .keyword, .attribute: Color(.syntaxKeyword)
        case .type: Color(.syntaxType)
        case .string: Color(.syntaxString)
        case .number: Color(.syntaxNumber)
        case .member: Color(.syntaxFunction)
        case .comment: Color(.syntaxComment)
        }
    }

    static func highlighted(_ source: String, language: String) -> AttributedString {
        CodeTokenizer(language: language).tokenize(source).reduce(into: AttributedString()) { result, token in
            var piece = AttributedString(token.text)
            piece.foregroundColor = color(for: token.kind)
            result += piece
        }
    }
}
