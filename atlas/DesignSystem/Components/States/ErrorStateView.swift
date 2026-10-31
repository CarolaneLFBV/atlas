import SwiftUI

struct ErrorStateView: View {
    let title: LocalizedStringResource
    let message: String
    var retry: (() -> Void)?

    var body: some View {
        ContentUnavailableView {
            VStack(spacing: Spacing.s16) {
                Text(verbatim: "!")
                    .font(.title.bold())
                    .foregroundStyle(AtlasColor.dangerText)
                    .frame(width: 56, height: 56)
                    .background(AtlasColor.dangerFill, in: Circle())
                    .accessibilityHidden(true)
                Text(title)
                    .font(.atlasSectionHeading)
            }
        } description: {
            Text(message)
        } actions: {
            if let retry {
                Button(.errorStateRetryButton, action: retry)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(AtlasColor.primaryText)
                    .padding(.horizontal, Spacing.s20)
                    .frame(minHeight: 40)
                    .background(AtlasColor.fill, in: Capsule())
                    .buttonStyle(.plain)
            }
        }
        .accessibilityIdentifier("state.error")
    }
}

#if DEBUG
#Preview {
    ErrorStateView(
        title: "Couldn't Load Page",
        message: "Check your connection, or try again in a moment."
    ) {}
}
#endif
