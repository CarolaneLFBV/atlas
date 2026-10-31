import SwiftUI

struct DisabledSourcesNotice: View {
    let sources: [DocumentationSourceStatus]

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.inline) {
            Label {
                Text(sources.map(\.displayName).formatted(.list(type: .and)))
                    .font(.atlasRowTitle)
            } icon: {
                Image(systemName: "pause.circle")
                    .foregroundStyle(.secondary)
            }
            Text(.libraryDisabledSourcesMessage)
                .font(.atlasSecondary)
                .foregroundStyle(.secondary)
            if let url = URL(string: "https://developer.apple.com/documentation") {
                Link(destination: url) {
                    Label(.libraryDisabledSourcesOpenWebsite, systemImage: AtlasSymbol.openExternal)
                        .font(.atlasSecondary)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .cardSurface()
        .accessibilityElement(children: .combine)
    }
}

#if DEBUG
#Preview {
    DisabledSourcesNotice(sources: [DocumentationSourceStatus(id: .apple, displayName: "Apple Developer Documentation", isEnabled: false)])
        .padding()
}
#endif
