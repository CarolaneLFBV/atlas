import SwiftUI

struct CategoryFrameworksView: View {
    let category: DocumentationCatalogue.Category

    var body: some View {
        List(category.frameworks) { framework in
            DocumentationLink(entry: framework.entry) {
                HStack(spacing: Spacing.s12) {
                    FrameworkTile(framework.title, size: 30)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(framework.title)
                            .font(.atlasRowTitle)
                            .foregroundStyle(AtlasColor.primaryText)
                        if let abstract = framework.abstract {
                            InlineMarkdownText(abstract)
                                .font(.atlasSecondary)
                                .foregroundStyle(AtlasColor.secondaryText)
                                .lineLimit(2)
                        }
                    }
                }
                .padding(.vertical, Spacing.tight)
            }
        }
        .navigationTitle(category.name)
    }
}
