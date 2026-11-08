import SwiftUI

struct FeaturedSection: View {
    let frameworks: [DocumentationFramework]

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.s12) {
            SectionHeader(.libraryFeaturedHeader)
            if let hero = frameworks.first {
                FeaturedFrameworkLink(framework: hero) {
                    FeaturedHeroCard(title: hero.title, subtitle: hero.abstract ?? hero.category)
                }
            }
            let others = Array(frameworks.dropFirst())
            if !others.isEmpty {
                // Grid rows share the tallest card's height, so cards with and without figures align.
                Grid(alignment: .top, horizontalSpacing: Spacing.s12) {
                    GridRow {
                        ForEach(others) { framework in
                            FeaturedFrameworkLink(framework: framework) {
                                FeaturedCard(title: framework.title, subtitle: framework.category)
                            }
                            .frame(maxHeight: .infinity)
                        }
                    }
                }
            }
        }
    }
}
