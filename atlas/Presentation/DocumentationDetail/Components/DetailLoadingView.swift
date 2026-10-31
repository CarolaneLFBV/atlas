import SwiftUI

struct DetailLoadingView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.s16) {
            Radius.shape(Radius.list).fill(AtlasColor.fill).frame(height: 76)
            ForEach(0..<5, id: \.self) { line in
                Capsule().fill(AtlasColor.fill)
                    .frame(maxWidth: line == 4 ? 180 : .infinity)
                    .frame(height: 12)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(.detailLoadingLabel)
    }
}
