import SwiftUI

struct FilterChip: View {
    let title: String
    var count: Int?
    var frameworkName: String?
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: Spacing.inline) {
                if let frameworkName {
                    FrameworkDot(frameworkName: frameworkName, size: 8)
                }
                Text(verbatim: count.map { "\(title) · \($0)" } ?? title)
            }
            .font(.subheadline.weight(.medium))
            .foregroundStyle(isSelected ? AtlasColor.background : AtlasColor.primaryText)
            .padding(.horizontal, Spacing.s12 + 2)
            .frame(minHeight: Sizing.chipHeight)
            .background(isSelected ? AtlasColor.primaryText : AtlasColor.fill, in: Capsule())
            .contentShape(Capsule())
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

#if DEBUG
#Preview {
    HStack {
        FilterChip(title: "All", count: 12, isSelected: true) {}
        FilterChip(title: "SwiftUI", frameworkName: "SwiftUI", isSelected: false) {}
        FilterChip(title: "Articles", isSelected: false) {}
    }
    .padding()
}
#endif
