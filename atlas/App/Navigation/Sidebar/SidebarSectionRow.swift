import SwiftUI

struct SidebarSectionRow: View {
    let section: AppSection
    var badge = 0

    var body: some View {
        Label(section.title, systemImage: section.systemImage)
            .badge(badge)
            .accessibilityIdentifier("sidebar.\(section.rawValue)")
    }
}
