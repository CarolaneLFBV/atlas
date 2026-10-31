import SwiftUI

struct OfficialDocumentationCard: View {
    let url: URL?
    let reason: String

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.stack) {
            Label(.officialDocsTitle, systemImage: AtlasSymbol.openExternal)
                .font(.atlasRowTitle)
            Text(reason)
                .font(.atlasSecondary)
                .foregroundStyle(AtlasColor.secondaryText)
            if let url {
                Link(destination: url) {
                    Text(.officialDocsOpenButton)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .accessibilityIdentifier("detail.openOfficial")
            }
        }
        .cardSurface()
    }
}

#if DEBUG
#Preview {
    OfficialDocumentationCard(
        url: URL(string: "https://developer.apple.com/documentation/swiftui"),
        reason: DocumentationError.sourceDisabled(.apple).userMessage
    )
    .padding()
}
#endif
