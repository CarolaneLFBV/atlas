import SwiftUI

struct FeaturedSection: View {
    let frameworks: [DocumentationFramework]

    @Environment(\.openDocumentation) private var openDocumentation

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.s12) {
            SectionHeader(.libraryFeaturedHeader)
            if let hero = frameworks.first {
                link(to: hero) {
                    FeaturedHeroCard(title: hero.title, subtitle: hero.abstract ?? hero.category)
                }
            }
            let others = Array(frameworks.dropFirst())
            if !others.isEmpty {
                // Grid rows share the tallest card's height, so cards with and without figures align.
                Grid(alignment: .top, horizontalSpacing: Spacing.s12) {
                    GridRow {
                        ForEach(others) { framework in
                            link(to: framework) {
                                FeaturedCard(title: framework.title, subtitle: framework.category)
                            }
                            .frame(maxHeight: .infinity)
                        }
                    }
                }
            }
        }
    }

    private func link(to framework: DocumentationFramework, @ViewBuilder label: () -> some View) -> some View {
        Button {
            openDocumentation(framework.entry)
        } label: {
            label()
        }
        .buttonStyle(.plain)
        .documentationContextMenu(for: framework.entry)
        .accessibilityIdentifier("library.framework.\(framework.title)")
    }
}
