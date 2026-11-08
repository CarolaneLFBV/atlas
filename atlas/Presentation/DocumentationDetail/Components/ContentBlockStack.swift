import SwiftUI

struct ContentBlockStack: View {
    let blocks: [ContentBlock]
    var saveSnippet: ((CodeSnippet) -> Void)?
    var frameworkName: String?

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.stack) {
            ForEach(Array(blocks.enumerated()), id: \.offset) { _, block in
                ContentBlockView(block: block, saveSnippet: saveSnippet, frameworkName: frameworkName)
            }
        }
    }
}
