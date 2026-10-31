import SwiftUI

struct ReduceMotionAnimationModifier<Value: Equatable>: ViewModifier {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    let animation: Animation
    let value: Value

    func body(content: Content) -> some View {
        content.animation(reduceMotion ? nil : animation, value: value)
    }
}

extension View {
    /// Animates changes to `value` with a `Motion` token, respecting Reduce Motion.
    func atlasAnimation<Value: Equatable>(_ animation: Animation = Motion.standard, value: Value) -> some View {
        modifier(ReduceMotionAnimationModifier(animation: animation, value: value))
    }
}
