import SwiftUI

struct SearchResultSectionHeader: View {
    let title: LocalizedStringResource
    let count: Int

    var body: some View {
        HStack {
            Text(title).atlasEyebrow()
            Spacer()
            Text(count, format: .number).font(.atlasMonoMeta)
                .foregroundStyle(AtlasColor.tertiaryText)
        }
        .foregroundStyle(AtlasColor.secondaryText)
    }
}
