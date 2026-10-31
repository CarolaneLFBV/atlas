import SwiftUI

struct FrameworkGridCell: View {
    let title: String
    var subtitle: String?

    var body: some View {
        HStack(spacing: Spacing.s12 - 2) {
            FrameworkTile(title, size: 30)
            VStack(alignment: .leading, spacing: 1) {
                Text(verbatim: title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(AtlasColor.primaryText)
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)
                if let subtitle {
                    Text(verbatim: subtitle)
                        .font(.caption2)
                        .foregroundStyle(AtlasColor.secondaryText)
                        .lineLimit(1)
                }
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, Spacing.s12 - 2)
        .padding(.vertical, Spacing.inline)
        .frame(maxWidth: .infinity, minHeight: Sizing.frameworkCellHeight)
        .cardSurface(padding: 0)
        .contentShape(Radius.shape(Radius.list))
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isButton)
    }
}

#if DEBUG
#Preview {
    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: Spacing.s12) {
        FrameworkGridCell(title: "Foundation", subtitle: "Preview fixture")
        FrameworkGridCell(title: "UIKit")
        FrameworkGridCell(title: "Core ML")
        FrameworkGridCell(title: "Combine")
    }
    .padding()
    .background(AtlasColor.background)
}
#endif
