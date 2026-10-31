import SwiftUI

struct AsideView<Content: View>: View {
    let style: ContentBlock.AsideStyle
    let title: String?
    @ViewBuilder var content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.inline) {
            Label(title ?? defaultTitle, systemImage: symbol)
                .atlasEyebrow()
                .foregroundStyle(tint)
            content()
        }
        .padding(Spacing.cardPadding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(tint.opacity(0.08), in: Radius.shape(Radius.list))
        .overlay(alignment: .leading) {
            Rectangle().fill(tint).frame(width: 3).clipShape(Radius.shape(Radius.badge))
        }
        .accessibilityElement(children: .combine)
    }

    private var tint: Color {
        switch style {
        case .note, .experiment: AtlasColor.accent
        case .tip: AtlasColor.success
        case .important: AtlasColor.warning
        case .warning, .deprecated: AtlasColor.danger
        }
    }

    private var symbol: String {
        switch style {
        case .note: "note.text"
        case .tip: "lightbulb"
        case .important: "exclamationmark.circle"
        case .warning: "exclamationmark.triangle"
        case .experiment: "flask"
        case .deprecated: "xmark.octagon"
        }
    }

    private var defaultTitle: String {
        switch style {
        case .note: String(localized: .asideNote)
        case .tip: String(localized: .asideTip)
        case .important: String(localized: .asideImportant)
        case .warning: String(localized: .asideWarning)
        case .experiment: String(localized: .asideExperiment)
        case .deprecated: String(localized: .asideDeprecated)
        }
    }
}

#if DEBUG
#Preview {
    AsideView(style: .tip, title: nil) {
        Text(PreviewFixtures.fixtureProse)
    }
    .padding()
}
#endif
