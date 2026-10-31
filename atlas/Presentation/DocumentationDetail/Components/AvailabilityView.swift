import SwiftUI

struct AvailabilityView: View {
    let availability: [PlatformAvailability]
    var frameworkName: String?

    var body: some View {
        FlowLayout(spacing: Spacing.s12) {
            ForEach(availability, id: \.platform) { item in
                HStack(spacing: Spacing.tight + 1) {
                    FrameworkDot(frameworkName: frameworkName)
                    Text(verbatim: item.introducedAt.map { "\(item.platform) \($0)+" } ?? item.platform)
                    if item.isBeta {
                        StatusBadge(text: .badgeBeta, style: .beta)
                    }
                    if item.deprecatedAt != nil {
                        StatusBadge(text: .badgeDeprecated, style: .deprecated)
                    }
                }
                .font(.atlasMonoMeta)
                .foregroundStyle(AtlasColor.secondaryText)
                .accessibilityElement(children: .combine)
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel(.detailAvailabilityLabel)
    }
}

#if DEBUG
#Preview {
    AvailabilityView(availability: PreviewFixtures.detail.availability, frameworkName: "SwiftUI")
        .padding()
}
#endif
