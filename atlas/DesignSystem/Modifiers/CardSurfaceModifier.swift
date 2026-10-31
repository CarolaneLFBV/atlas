import SwiftUI

struct CardSurfaceModifier: ViewModifier {
    var padding: CGFloat
    var radius: CGFloat
    var fill: Color

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(fill, in: Radius.shape(radius))
            .overlay(Radius.shape(radius).strokeBorder(AtlasColor.separator, lineWidth: Sizing.hairline))
    }
}

extension View {
    func cardSurface(
        padding: CGFloat = Spacing.cardPadding,
        radius: CGFloat = Radius.list,
        fill: Color = AtlasColor.surface
    ) -> some View {
        modifier(CardSurfaceModifier(padding: padding, radius: radius, fill: fill))
    }
}
