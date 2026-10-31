import SwiftUI

/// The caller owns the state; the button only forwards the tap.
struct BookmarkButton: View {
    let isBookmarked: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Label(
                isBookmarked ? .bookmarkButtonRemove : .bookmarkButtonAdd,
                systemImage: isBookmarked ? AtlasSymbol.bookmarkFilled : AtlasSymbol.bookmark
            )
        }
        .tint(AtlasColor.accent)
        .symbolEffect(.bounce, value: isBookmarked)
        .sensoryFeedback(.success, trigger: isBookmarked) { _, saved in saved }
        .accessibilityIdentifier("bookmarkButton")
    }
}

#if DEBUG
#Preview {
    @Previewable @State var isBookmarked = false
    BookmarkButton(isBookmarked: isBookmarked) { isBookmarked.toggle() }
        .padding()
}
#endif
