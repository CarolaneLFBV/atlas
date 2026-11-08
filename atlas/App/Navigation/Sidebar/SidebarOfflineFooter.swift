import SwiftUI

struct SidebarOfflineFooter: View {
    let lastUpdated: Date

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: Spacing.tight) {
            Circle().fill(AtlasColor.success).frame(width: Sizing.frameworkDot, height: Sizing.frameworkDot)
            Text(.sidebarOfflineFooter(date: lastUpdated.formatted(.relative(presentation: .named))))
                .lineLimit(1)
                .minimumScaleFactor(0.85)
        }
        .font(.atlasCaption)
        .foregroundStyle(AtlasColor.secondaryText)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, Spacing.s20)
        .padding(.vertical, Spacing.s12)
        .accessibilityElement(children: .combine)
    }
}
