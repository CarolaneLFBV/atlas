import SwiftUI

/// Code is displayed as text only; it is never executed.
struct CodeSnippetView: View {
    let code: String
    var language: String = "swift"
    /// File name or snippet title; the language is shown when there is none.
    var title: String?
    var frameworkName: String?
    /// Pre-colored text, for callers that already have syntax tokens (e.g. DocC declarations).
    /// When `nil`, `code` is highlighted with `CodeTokenizer`.
    var highlighted: AttributedString?
    var showsLineNumbers = true
    /// Shows only the first lines (lists of snippets); Copy still copies everything.
    var displayLineLimit: Int?
    var saveAction: (() -> Void)?

    private var lines: [Substring] { code.split(separator: "\n", omittingEmptySubsequences: false) }

    private var displayedCode: String {
        guard let displayLineLimit, lines.count > displayLineLimit else { return code }
        return lines.prefix(displayLineLimit).joined(separator: "\n") + "\n…"
    }

    private var displayedLineCount: Int { displayedCode.split(separator: "\n", omittingEmptySubsequences: false).count }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            CodeSnippetHeader(code: code, language: language, title: title, frameworkName: frameworkName, saveAction: saveAction)
            HairlineDivider()
            HStack(alignment: .top, spacing: Spacing.s12) {
                if showsLineNumbers {
                    CodeLineNumbers(count: displayedLineCount)
                }
                ScrollView(.horizontal) {
                    Text(highlighted ?? CodeTheme.highlighted(displayedCode, language: language))
                        .font(.atlasCode)
                        .lineSpacing(Self.lineSpacing)
                        .textSelection(.enabled)
                        .fixedSize(horizontal: true, vertical: false)
                }
                .scrollIndicators(.hidden)
            }
            .padding(Spacing.s12 + 2)
        }
        .background(AtlasColor.codeBackground, in: Radius.shape(Radius.list))
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("codeSnippet")
    }

    /// 13 pt code on 20 pt lines.
    static let lineSpacing: CGFloat = 4
}

#if DEBUG
#Preview {
    CodeSnippetView(
        code: """
        // Preview fixture
        @main struct MyApp: App {
            var body: some Scene {
                WindowGroup { Text("Hello, \\(name)") }
            }
        }
        """,
        title: "MyApp.swift",
        frameworkName: "Foundation",
        saveAction: {}
    )
    .padding()
    .toastHost()
}
#endif
