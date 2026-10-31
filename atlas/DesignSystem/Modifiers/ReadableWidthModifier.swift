import SwiftUI

struct ReadableWidthModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .frame(maxWidth: Sizing.readableContentWidth, alignment: .leading)
            .frame(maxWidth: .infinity)
    }
}

extension View {
    func readableWidth() -> some View {
        modifier(ReadableWidthModifier())
    }
}
