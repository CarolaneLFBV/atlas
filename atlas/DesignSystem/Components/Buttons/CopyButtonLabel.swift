import SwiftUI

struct CopyButtonLabel: View {
    let style: CopyButton.Style
    let didCopy: Bool

    var body: some View {
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
