import SwiftUI

struct ContentBlockView: View {
    let block: ContentBlock
    /// Called when the user saves a code example. `nil` when the source doesn't permit saving.
    var saveSnippet: ((CodeSnippet) -> Void)?
    var frameworkName: String?

    var body: some View {
        switch block {
        case .heading(let level, let text):
            if level <= 2 {
                DetailSectionTitle(text).padding(.top, Spacing.inline)
            } else {
                Text(text)
                    .font(.atlasSectionHeading)
                    .padding(.top, Spacing.inline)
                    .accessibilityAddTraits(.isHeader)
            }

        case .paragraph(let elements):
            Text(InlineTextRenderer.attributedString(from: elements))
                .font(.atlasBody)
                .lineSpacing(Spacing.s8 - 1) // 16 pt prose on 24 pt lines.
                .foregroundStyle(AtlasColor.primaryText)
                .textSelection(.enabled)
                .fixedSize(horizontal: false, vertical: true)

        case .code(let snippet):
            CodeSnippetView(
                code: snippet.code,
                language: snippet.language,
                title: snippet.title.isEmpty ? nil : snippet.title,
                frameworkName: frameworkName,
                saveAction: saveSnippet.map { save in { save(snippet) } }
            )

        case .list(let ordered, let items):
            VStack(alignment: .leading, spacing: Spacing.inline) {
                ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                    HStack(alignment: .firstTextBaseline, spacing: Spacing.inline) {
                        Text(verbatim: ordered ? "\(index + 1)." : "•")
                            .font(.atlasBody)
                            .foregroundStyle(.secondary)
                            .accessibilityHidden(true)
                        blocks(item)
                    }
                }
            }

        case .aside(let style, let title, let content):
            AsideView(style: style, title: title) {
                blocks(content)
            }

        case .unsupported(let kind):
            Label(.detailUnsupportedBlock(kind: kind), systemImage: "rectangle.dashed")
                .font(.atlasSecondary)
                .foregroundStyle(.secondary)
        }
    }

    private func blocks(_ blocks: [ContentBlock]) -> some View {
        VStack(alignment: .leading, spacing: Spacing.stack) {
            ForEach(Array(blocks.enumerated()), id: \.offset) { _, block in
                ContentBlockView(block: block, saveSnippet: saveSnippet, frameworkName: frameworkName)
            }
        }
    }
}
