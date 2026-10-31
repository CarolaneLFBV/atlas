import SwiftUI

/// Announced to VoiceOver as a single element.
struct LoadingStateView: View {
    var title: LocalizedStringResource = .loadingStateDefault

    var body: some View {
        VStack(spacing: Spacing.stack) {
            ProgressView()
            Text(title)
                .font(.atlasSecondary)
                .foregroundStyle(.secondary)
        }
        .padding(Spacing.stateInset)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("state.loading")
    }
}

#if DEBUG
#Preview {
    LoadingStateView()
}
#endif
