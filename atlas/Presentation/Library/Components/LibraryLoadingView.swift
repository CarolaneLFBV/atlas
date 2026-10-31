import SwiftUI

/// The Library while the catalogue loads: the real layout, redacted, so the screen doesn't jump when content arrives.
struct LibraryLoadingView: View {
    /// Placeholder shapes only: the text is never readable (`.redacted`) and is not content.
    private static let placeholders = (0..<LibraryViewModel.featuredCount).map { index in
        DocumentationFramework(
            id: DocumentationID(sourceID: DocumentationSourceID(rawValue: "placeholder"), path: "/placeholder/\(index)"),
            title: "Placeholder title", abstract: nil, category: "Placeholder", tags: [], webURL: nil
        )
    }

    var body: some View {
        FeaturedSection(frameworks: Self.placeholders)
            .redacted(reason: .placeholder)
            .allowsHitTesting(false)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(.libraryLoadingLabel)
    }
}
