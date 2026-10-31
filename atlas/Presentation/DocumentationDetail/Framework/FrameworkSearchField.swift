import SwiftUI

struct FrameworkSearchField: View {
    let frameworkName: String
    @Binding var text: String

    var body: some View {
        HStack(spacing: Spacing.inline) {
            Image(systemName: AtlasSymbol.search)
                .foregroundStyle(AtlasColor.secondaryText)
                .accessibilityHidden(true)
            TextField(.frameworkSearchPrompt(framework: frameworkName), text: $text)
                .autocorrectionDisabled()
                #if os(iOS)
                .textInputAutocapitalization(.never)
                #endif
                .submitLabel(.search)
            if !text.isEmpty {
                Button(.frameworkSearchClear, systemImage: AtlasSymbol.clear) { text = "" }
                    .labelStyle(.iconOnly)
                    .foregroundStyle(AtlasColor.tertiaryText)
                    .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, Spacing.s8 + 2)
        .frame(minHeight: 36)
        .background(AtlasColor.fill, in: Radius.shape(Radius.field))
        .accessibilityIdentifier("framework.search")
    }
}
