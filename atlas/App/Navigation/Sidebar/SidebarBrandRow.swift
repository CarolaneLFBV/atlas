import SwiftUI

struct SidebarBrandRow: View {
    var body: some View {
        HStack(spacing: Spacing.inline) {
            MonogramTile(text: "A", tint: AtlasColor.accent, size: 26, style: .solid)
            Text(verbatim: "Atlas").font(.headline)
        }
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isHeader)
        .selectionDisabled()
    }
}
