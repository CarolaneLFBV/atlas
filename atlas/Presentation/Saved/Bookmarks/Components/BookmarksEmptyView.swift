import SwiftUI

struct BookmarksEmptyView: View {
    @Environment(\.showSection) private var showSection

    var body: some View {
        ContentUnavailableView {
            VStack(spacing: Spacing.s20) {
                ZStack {
                    Radius.shape(Radius.card)
                        .fill(AtlasColor.accent.opacity(0.10))
                        .frame(width: 96, height: 72)
                        .rotationEffect(.degrees(-10))
                        .offset(x: 12, y: -10)
                    Radius.shape(Radius.card)
                        .fill(AtlasColor.accent.opacity(0.16))
                        .strokeBorder(.white.opacity(0.8), lineWidth: 1)
                        .frame(width: 96, height: 72)
                        .rotationEffect(.degrees(-10))
                    Image(systemName: AtlasSymbol.bookmarkFilled)
                        .font(.system(size: 28))
                        .foregroundStyle(AtlasColor.accent)
                }
                .accessibilityHidden(true)
                Text(.bookmarksEmptyTitle)
                    .font(.atlasSectionHeading)
            }
        } description: {
            Text(.bookmarksEmptyMessage)
                .font(.subheadline)
        } actions: {
            Button(.bookmarksEmptyBrowseButton) { showSection(.library) }
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.white)
                .padding(.horizontal, Spacing.s20)
                .frame(minHeight: 40)
                .background(AtlasColor.accent, in: Capsule())
                .buttonStyle(.plain)
        }
    }
}

#if DEBUG
#Preview {
    BookmarksEmptyView()
}
#endif
