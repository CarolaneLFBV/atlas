import SwiftUI

struct FrameworkGrid: View {
    let category: DocumentationCatalogue.Category
    /// Frameworks shown before "See All".
    var limit = 8

    @Environment(\.openDocumentation) private var openDocumentation

    private let columns = [
        GridItem(.adaptive(minimum: Sizing.frameworkCardMinimumWidth), spacing: Spacing.s12, alignment: .top),
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.s12) {
            SectionHeader(verbatim: category.name) {
                if category.frameworks.count > limit {
                    NavigationLink(.librarySeeAll) {
                        CategoryFrameworksView(category: category)
                    }
                }
            }
            LazyVGrid(columns: columns, spacing: Spacing.s12) {
                ForEach(category.frameworks.prefix(limit)) { framework in
                    Button {
                        openDocumentation(framework.entry)
                    } label: {
                        // The section header already names the category, so cells show the abstract instead.
                        FrameworkGridCell(title: framework.title, subtitle: framework.abstract)
                    }
                    .buttonStyle(.plain)
                    .documentationContextMenu(for: framework.entry)
                    .accessibilityIdentifier("library.framework.\(framework.title)")
                }
            }
        }
    }
}
