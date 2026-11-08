import SwiftUI

struct CodeSnippetHeader: View {
    let code: String
    let language: String
    let title: String?
    let frameworkName: String?
    let saveAction: (() -> Void)?

    var body: some View {
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
}
