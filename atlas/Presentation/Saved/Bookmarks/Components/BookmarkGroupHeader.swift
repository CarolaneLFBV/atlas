import SwiftUI

struct BookmarkGroupHeader: View {
    let frameworkName: String
    let count: Int

    var body: some View {
        HStack(spacing: Spacing.inline) {
            FrameworkDot(frameworkName: frameworkName, size: 8)
            Text(frameworkName)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(AtlasColor.primaryText)
            Spacer()
            Text(count, format: .number)
                .font(.atlasMonoMeta)
                .foregroundStyle(AtlasColor.tertiaryText)
        }
        .textCase(nil)
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isHeader)
    }
}
