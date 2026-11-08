import SwiftUI

struct SnippetFilterBar: View {
    @Binding var selection: SnippetFilter
    let totalCount: Int

    var body: some View {
        ScrollView(.horizontal) {
            HStack(spacing: Spacing.inline) {
                ForEach(SnippetFilter.allCases, id: \.self) { option in
                    FilterChip(
                        title: option.title,
                        count: option == .all ? totalCount : nil,
                        isSelected: selection == option
                    ) { selection = option }
                }
            }
        }
        .scrollIndicators(.hidden)
        .scrollClipDisabled()
    }
}
