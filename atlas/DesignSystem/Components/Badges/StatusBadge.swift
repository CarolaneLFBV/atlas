import SwiftUI

struct StatusBadge: View {
    enum Style {
        case neutral
        case beta
        case deprecated
    }

    let text: LocalizedStringResource
    var style: Style = .neutral

    var body: some View {
        Text(text)
            .font(.atlasMonoMeta)
            .foregroundStyle(foreground)
            .padding(.horizontal, Spacing.s4 + 2)
            .padding(.vertical, 2)
            .background(background, in: Radius.shape(Radius.badge))
    }

    private var foreground: Color {
        switch style {
        case .neutral: AtlasColor.secondaryText
        case .beta: AtlasColor.warningText
        case .deprecated: AtlasColor.dangerText
        }
    }

    private var background: Color {
        switch style {
        case .neutral: AtlasColor.fill
        case .beta: AtlasColor.warningFill
        case .deprecated: AtlasColor.dangerFill
        }
    }
}

#if DEBUG
#Preview {
    HStack {
        StatusBadge(text: "iOS 16.0+")
        StatusBadge(text: "Beta", style: .beta)
        StatusBadge(text: "Deprecated", style: .deprecated)
    }
    .padding()
}
#endif
