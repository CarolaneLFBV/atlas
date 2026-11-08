import SwiftUI

struct HairlineDivider: View {
    var body: some View {
        Rectangle().fill(AtlasColor.separator).frame(height: Sizing.hairline)
    }
}
