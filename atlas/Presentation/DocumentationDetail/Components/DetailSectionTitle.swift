import SwiftUI

struct DetailSectionTitle: View {
    private let title: Text

    /// For titles that are data, such as a section heading of a page, shown as is.
    init(_ title: String) {
        self.title = Text(verbatim: title)
    }

    init(_ title: LocalizedStringResource) {
        self.title = Text(title)
    }

    var body: some View {
        title
            .font(.atlasSectionTitle)
            .tracking(-0.3)
            .foregroundStyle(AtlasColor.primaryText)
            .accessibilityAddTraits(.isHeader)
    }
}
