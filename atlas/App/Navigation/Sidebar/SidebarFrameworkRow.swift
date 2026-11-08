import SwiftUI

struct SidebarFrameworkRow: View {
    let title: String

    var body: some View {
        Label {
            Text(title).lineLimit(1)
        } icon: {
            FrameworkTile(title, size: 22, style: .solid)
        }
    }
}
