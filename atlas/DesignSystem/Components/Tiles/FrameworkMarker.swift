import SwiftUI

struct FrameworkMarker: View {
    let frameworkName: String

    var body: some View {
        HStack(spacing: Spacing.tight) {
            FrameworkDot(frameworkName: frameworkName)
            Text(frameworkName)
        }
    }
}
