import SwiftUI

/// Copies text and confirms it: the button turns into "Copied" (success colors) for 1.6 s and a
/// "Copied to clipboard" toast appears.
struct CopyButton: View {
    enum Style {
        /// "Copy" with an icon, on a fill (code block headers).
        case labeled
        /// Icon only, 28 pt (declarations).
        case icon
    }

    let text: String
    var style: Style = .labeled

    @State private var didCopy = false
    @Environment(\.showToast) private var showToast

    var body: some View {
        Button {
            Clipboard.copy(text)
            didCopy = true
            showToast(.copyButtonToast)
        } label: {
            label
                .font(.caption.weight(.semibold))
                .foregroundStyle(didCopy ? AtlasColor.success : AtlasColor.secondaryText)
                .padding(.horizontal, style == .labeled ? Spacing.s8 + 2 : 0)
                // Wide enough for "Copied", so the header doesn't shift when the label changes.
                .frame(minWidth: style == .labeled ? 78 : Sizing.copyButtonHeight, minHeight: Sizing.copyButtonHeight)
                .background(didCopy ? AtlasColor.successFill : AtlasColor.fill, in: Radius.shape(Radius.button))
                .contentShape(Rectangle().inset(by: -8))
        }
        .buttonStyle(.plain)
        .sensoryFeedback(.success, trigger: didCopy) { _, copied in copied }
        .accessibilityLabel(didCopy ? .copyButtonCopied : .copyButtonCopy)
        .accessibilityHint(.copyButtonHint)
        .accessibilityIdentifier("codeSnippet.copy")
        .task(id: didCopy) {
            guard didCopy else { return }
            try? await Task.sleep(for: .seconds(1.6)) // Cancelled when the view disappears; the reset is moot then.
            didCopy = false
        }
    }

    @ViewBuilder
    private var label: some View {
        let symbol = Image(systemName: didCopy ? AtlasSymbol.copied : AtlasSymbol.copy)
            .contentTransition(.symbolEffect(.replace))
        switch style {
        case .labeled:
            HStack(spacing: Spacing.tight) {
                symbol
                Text(didCopy ? .copyButtonCopied : .copyButtonCopy)
            }
        case .icon:
            symbol
        }
    }
}

#if DEBUG
#Preview {
    HStack {
        CopyButton(text: "let x = 1")
        CopyButton(text: "let x = 1", style: .icon)
    }
    .padding()
    .toastHost()
}
#endif
