import Testing
@testable import atlas

@Suite("CodeTokenizer")
struct CodeTokenizerTests {
    let swift = CodeTokenizer(language: "swift")

    @Test("Tokens always reassemble to the original source", arguments: [
        "struct A: View { var body: some View { Text(\"Hi \\(name)\") } }",
        "// comment\nlet x = 1_000.5 /* block */",
        "@MainActor final class Model {}\n#Preview { }",
        "let unterminated = \"oops",
        "/* unterminated block",
        "",
    ])
    func roundTrip(_ source: String) {
        #expect(swift.tokenize(source).map(\.text).joined() == source)
    }

    @Test("Swift constructs are classified")
    func classification() {
        let tokens = swift.tokenize("@State private var count: Int = 42 // note")
        func kind(of text: String) -> CodeTokenizer.Kind? { tokens.first { $0.text == text }?.kind }
        #expect(kind(of: "@State") == .attribute)
        #expect(kind(of: "private") == .keyword)
        #expect(kind(of: "Int") == .type)
        #expect(kind(of: "42") == .number)
        #expect(kind(of: "// note") == .comment)
    }

    @Test("Calls and member accesses are classified as members; other names stay plain")
    func members() {
        let tokens = swift.tokenize("let count = items.count + total(x)")
        // Only `.count` and `total(` are members; the declared `count` and `items` stay plain.
        #expect(tokens.filter { $0.kind == .member }.map(\.text) == ["count", "total"])
    }

    @Test("Escaped quotes stay inside the string")
    func escapedQuotes() {
        let tokens = swift.tokenize(#"let s = "a \"b\" c""#)
        #expect(tokens.last == .init(kind: .string, text: #""a \"b\" c""#))
    }

    @Test("Non-Swift languages do not get Swift keyword highlighting")
    func otherLanguages() {
        let tokens = CodeTokenizer(language: "shell").tokenize("let Value")
        #expect(tokens.allSatisfy { $0.kind == .plain })
    }
}
