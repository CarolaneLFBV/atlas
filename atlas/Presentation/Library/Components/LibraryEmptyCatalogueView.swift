import SwiftUI

struct LibraryEmptyCatalogueView: View {
    var body: some View {
        EmptyStateView(
            .libraryEmptyTitle,
            systemImage: AtlasSymbol.library,
            message: .libraryEmptyMessage
        )
        .frame(minHeight: 320)
    }
}
