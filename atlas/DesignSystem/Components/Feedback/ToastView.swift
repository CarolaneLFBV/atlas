import SwiftUI

struct ToastView: View {
    let message: LocalizedStringResource

    var body: some View {
        HStack(spacing: Spacing.inline) {
            Image(systemName: AtlasSymbol.confirmation)
                .font(.system(size: 20))
                .symbolRenderingMode(.palette)
                .foregroundStyle(AtlasColor.background, Color(red: 47 / 255, green: 179 / 255, blue: 138 / 255))
            Text(message)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(AtlasColor.background)
        }
        .padding(.leading, Spacing.s12)
        .padding(.trailing, Spacing.s16)
        .frame(minHeight: 40)
        .background(AtlasColor.primaryText, in: Capsule())
        .atlasShadow(.floating)
        .accessibilityHidden(true) // Announced by the host instead.
    }
}

#if DEBUG
#Preview {
    ToastView(message: "Copied to clipboard").padding()
}
#endif
