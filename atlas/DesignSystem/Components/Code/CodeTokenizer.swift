import Foundation

/// It does not parse or execute code.
///
/// Swift is highlighted fully; other languages get comments, strings and numbers only.
/// The tokens always concatenate back to the exact input, so copying is never affected.
nonisolated struct CodeTokenizer: Sendable {
    nonisolated enum Kind: Hashable, Sendable {
        case plain, keyword, type, string, number, comment, attribute
        /// A function call or member access (`.padding`, `print(`).
        case member
    }

    nonisolated struct Token: Hashable, Sendable {
        let kind: Kind
        let text: String
    }

    let language: String

    private var isSwift: Bool { ["swift", ""].contains(language.lowercased()) }

    static let swiftKeywords: Set<String> = [
        "actor", "associatedtype", "async", "await", "break", "case", "catch", "class", "consuming",
        "continue", "default", "defer", "deinit", "do", "else", "enum", "extension", "fallthrough",
        "false", "fileprivate", "final", "for", "func", "guard", "if", "import", "in", "init", "inout",
        "internal", "is", "isolated", "let", "lazy", "macro", "mutating", "nil", "nonisolated", "open",
        "operator", "override", "private", "protocol", "public", "repeat", "rethrows", "return", "self",
        "Self", "some", "any", "static", "struct", "subscript", "super", "switch", "throw", "throws",
        "true", "try", "typealias", "var", "weak", "where", "while", "get", "set", "willSet", "didSet",
    ]

    func tokenize(_ source: String) -> [Token] {
        let characters = Array(source)
        var tokens: [Token] = []
        var index = 0

        func append(_ kind: Kind, _ range: Range<Int>) {
            let text = String(characters[range])
            if let last = tokens.last, last.kind == kind {
                tokens[tokens.count - 1] = Token(kind: kind, text: last.text + text)
            } else {
                tokens.append(Token(kind: kind, text: text))
            }
        }

        func peek(_ offset: Int) -> Character? {
            let position = index + offset
            return position < characters.count ? characters[position] : nil
        }

        while index < characters.count {
            let start = index
            let character = characters[index]

            if character == "/" && peek(1) == "/" {
                while index < characters.count && characters[index] != "\n" { index += 1 }
                append(.comment, start..<index)
            } else if character == "/" && peek(1) == "*" {
                index += 2
                while index < characters.count && !(characters[index] == "*" && peek(1) == "/") { index += 1 }
                index = min(index + 2, characters.count)
                append(.comment, start..<index)
            } else if character == "\"" {
                index += 1
                while index < characters.count && characters[index] != "\"" && characters[index] != "\n" {
                    index += characters[index] == "\\" ? 2 : 1
                }
                index = min(index + 1, characters.count)
                append(.string, start..<index)
            } else if character.isNumber {
                while index < characters.count && (characters[index].isNumber || characters[index] == "." || characters[index] == "_") {
                    index += 1
                }
                append(.number, start..<index)
            } else if isSwift && (character == "@" || character == "#") && (peek(1)?.isLetter ?? false) {
                index += 1
                while index < characters.count && Self.isIdentifierCharacter(characters[index]) { index += 1 }
                append(.attribute, start..<index)
            } else if Self.isIdentifierStart(character) {
                while index < characters.count && Self.isIdentifierCharacter(characters[index]) { index += 1 }
                let word = String(characters[start..<index])
                let kind: Kind
                if isSwift && Self.swiftKeywords.contains(word) {
                    kind = .keyword
                } else if isSwift && word.first?.isUppercase == true {
                    kind = .type
                } else if isSwift && ((start > 0 && characters[start - 1] == ".") || peek(0) == "(") {
                    kind = .member
                } else {
                    kind = .plain
                }
                append(kind, start..<index)
            } else {
                index += 1
                append(.plain, start..<index)
            }
        }
        return tokens
    }

    private static func isIdentifierStart(_ character: Character) -> Bool {
        character.isLetter || character == "_"
    }

    private static func isIdentifierCharacter(_ character: Character) -> Bool {
        character.isLetter || character.isNumber || character == "_"
    }
}
