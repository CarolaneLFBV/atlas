import SwiftUI

/// A search field look-alike at the top of the Library. Tapping it moves to search, where typing happens.
struct LibrarySearchField: View {
    @Environment(\.showSection) private var showSection

    var body: some View {
        Button { showSection(.search) } label: {
            HStack(spacing: Spacing.inline) {
                Image(systemName: AtlasSymbol.search)
                    .foregroundStyle(AtlasColor.secondaryText)
                Text(.librarySearchPrompt)
                    .foregroundStyle(AtlasColor.secondaryText)
                Spacer(minLength: 0)
            }
            .font(.body)
            .padding(.horizontal, Spacing.s8 + 2)
            .frame(minHeight: 36)
            .background(AtlasColor.fill, in: Radius.shape(Radius.field))
            .contentShape(Radius.shape(Radius.field))
        }
        .buttonStyle(.plain)
        .accessibilityLabel(.sectionSearch)
        .accessibilityHint(.librarySearchHint)
        .accessibilityIdentifier("library.search")
    }
}

#if DEBUG
#Preview {
    LibrarySearchField().padding()
}
#endif
