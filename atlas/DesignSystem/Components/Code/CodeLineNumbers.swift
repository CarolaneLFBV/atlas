import SwiftUI

struct CodeLineNumbers: View {
    let count: Int

    var body: some View {
        VStack(alignment: .trailing, spacing: 0) {
            Text(verbatim: (1...max(count, 1)).map(String.init).joined(separator: "\n"))
                .font(.atlasCode)
                .lineSpacing(CodeSnippetView.lineSpacing)
                .multilineTextAlignment(.trailing)
        }
        .foregroundStyle(AtlasColor.tertiaryText)
        .accessibilityHidden(true)
    }
}
