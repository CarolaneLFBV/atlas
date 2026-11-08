import SwiftUI

struct DetailProseSections: View {
    let sections: [DocumentationSection]
    let frameworkName: String?
    let saveSnippet: (CodeSnippet) -> Void

    var body: some View {
        ForEach(sections) { section in
            VStack(alignment: .leading, spacing: Spacing.s16) {
                DetailSectionTitle(section.title)
                ForEach(Array(section.blocks.enumerated()), id: \.offset) { _, block in
                    ContentBlockView(block: block, saveSnippet: saveSnippet, frameworkName: frameworkName)
                }
            }
        }
    }
}
