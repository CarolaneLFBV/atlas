import SwiftUI

struct DeclarationView: View {
    let declaration: Declaration

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.s8) {
            HStack {
                Text(.detailDeclarationHeader)
                    .atlasEyebrow()
                    .foregroundStyle(AtlasColor.secondaryText)
                Spacer()
                CopyButton(text: declaration.source, style: .icon)
            }
            ScrollView(.horizontal) {
                Text(attributedSource)
                    .font(.atlasDeclaration)
                    .lineSpacing(Spacing.s8) // 14 pt on 22 pt lines.
                    .textSelection(.enabled)
                    .fixedSize(horizontal: true, vertical: false)
            }
            .scrollIndicators(.hidden)
        }
        .padding(.horizontal, Spacing.s16)
        .padding(.vertical, Spacing.s12)
        .background(AtlasColor.codeBackground, in: Radius.shape(Radius.list))
        .accessibilityElement(children: .contain)
    }

    private var attributedSource: AttributedString {
        declaration.tokens.reduce(into: AttributedString()) { result, token in
            var piece = AttributedString(token.text)
            piece.foregroundColor = Self.color(for: token.kind)
            result += piece
        }
    }

    private static func color(for kind: Declaration.Token.Kind) -> Color {
        switch kind {
        case .keyword: CodeTheme.color(for: .keyword)
        case .attribute: CodeTheme.color(for: .attribute)
        case .typeIdentifier, .genericParameter: CodeTheme.color(for: .type)
        case .number: CodeTheme.color(for: .number)
        case .string: CodeTheme.color(for: .string)
        case .identifier: Color(.syntaxFunction)
        case .label, .parameter, .text: CodeTheme.color(for: .plain)
        }
    }
}

#if DEBUG
#Preview {
    if let declaration = PreviewFixtures.detail.declaration {
        DeclarationView(declaration: declaration).padding().toastHost()
    }
}
#endif
