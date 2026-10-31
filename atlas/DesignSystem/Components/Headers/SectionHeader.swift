import SwiftUI

struct SectionHeader<Accessory: View>: View {
    private let title: Text
    private var subtitle: Text?
    @ViewBuilder var accessory: () -> Accessory

    init(
        _ title: LocalizedStringResource,
        subtitle: LocalizedStringResource? = nil,
        @ViewBuilder accessory: @escaping () -> Accessory = { EmptyView() }
    ) {
        self.title = Text(title)
        self.subtitle = subtitle.map { Text($0) }
        self.accessory = accessory
    }

    /// For titles that are data, such as a category name, shown as is.
    init(
        verbatim title: String,
        @ViewBuilder accessory: @escaping () -> Accessory = { EmptyView() }
    ) {
        self.title = Text(verbatim: title)
        self.accessory = accessory
    }

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: Spacing.inline) {
            VStack(alignment: .leading, spacing: Spacing.tight) {
                title
                    .font(.atlasSectionHeading)
                    .tracking(-0.2)
                    .foregroundStyle(AtlasColor.primaryText)
                    .accessibilityAddTraits(.isHeader)
                if let subtitle {
                    subtitle
                        .font(.atlasSecondary)
                        .foregroundStyle(AtlasColor.secondaryText)
                }
            }
            Spacer(minLength: Spacing.inline)
            accessory()
                .font(.subheadline)
                .tint(AtlasColor.accent)
        }
    }
}

#if DEBUG
#Preview {
    SectionHeader("All Frameworks") {
        Button("See All") {}
    }
    .padding()
}
#endif
