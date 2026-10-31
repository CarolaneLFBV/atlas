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
            header
            Rectangle().fill(AtlasColor.separator).frame(height: Sizing.hairline)
            HStack(alignment: .top, spacing: Spacing.s12) {
                if showsLineNumbers {
                    lineNumbers
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
    private static let lineSpacing: CGFloat = 4

    private var header: some View {
        HStack(spacing: Spacing.inline) {
            FrameworkDot(frameworkName: frameworkName ?? title, size: 8)
            Text(verbatim: title ?? language.capitalized)
                .font(.atlasMonoMeta)
                .foregroundStyle(AtlasColor.secondaryText)
                .lineLimit(1)
            Spacer()
            if let saveAction {
                Button(action: saveAction) {
                    Image(systemName: AtlasSymbol.snippets)
                        .font(.footnote.weight(.semibold))
                        .frame(width: Sizing.minimumHitTarget, height: Sizing.minimumHitTarget)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.borderless)
                .accessibilityLabel(.codeSnippetSaveButton)
            }
            CopyButton(text: code)
        }
        .padding(.leading, Spacing.s12 + 2)
        .padding(.trailing, Spacing.inline)
        .frame(minHeight: Sizing.minimumHitTarget)
    }

    private var lineNumbers: some View {
        VStack(alignment: .trailing, spacing: 0) {
            Text(verbatim: (1...max(displayedLineCount, 1)).map(String.init).joined(separator: "\n"))
                .font(.atlasCode)
                .lineSpacing(Self.lineSpacing)
                .multilineTextAlignment(.trailing)
        }
        .foregroundStyle(AtlasColor.tertiaryText)
        .accessibilityHidden(true)
    }
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
