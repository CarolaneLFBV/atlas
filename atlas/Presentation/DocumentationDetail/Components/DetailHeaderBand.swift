import SwiftUI

/// The band of the framework's color, drawn behind the scroll view so it reaches the top of the
/// screen under the navigation bar, and moved with the scroll offset so it stays at the top of the
/// page. Only the band ignores the safe area; the content doesn't.
struct DetailHeaderBand: View {
    let frameworkName: String?
    let title: String
    let isFrameworkPage: Bool

    var body: some View {
        Group {
            if isFrameworkPage {
                DetailHeaderBackground(
                    frameworkName: frameworkName ?? title,
                    strength: 0.16, height: 460, planeWidth: 150, showsFullPlanes: true
                )
            } else {
                DetailHeaderBackground(frameworkName: frameworkName)
            }
        }
        .ignoresSafeArea(edges: .top)
    }
}
