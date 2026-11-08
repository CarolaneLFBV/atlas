import SwiftUI

struct LibraryLoadingContent: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.screenSection) {
                LibrarySearchField()
                LibraryLoadingView()
            }
            .padding(.horizontal, Spacing.contentMargin)
            .readableWidth()
        }
    }
}
