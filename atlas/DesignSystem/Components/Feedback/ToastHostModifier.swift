import SwiftUI

struct ToastHostModifier: ViewModifier {
    @State private var message: LocalizedStringResource?
    @State private var generation = 0
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func body(content: Content) -> some View {
        content
            .environment(\.showToast, ToastAction { newMessage in
                message = newMessage
                generation += 1
                AccessibilityNotification.Announcement(String(localized: newMessage)).post()
            })
            .overlay(alignment: .bottom) {
                if let message {
                    ToastView(message: message)
                        .padding(.bottom, Spacing.s64 + Spacing.s24)
                        .transition(reduceMotion ? .opacity : .move(edge: .bottom).combined(with: .opacity))
                }
            }
            .animation(reduceMotion ? .default : Motion.toast, value: message == nil)
            .task(id: generation) {
                guard message != nil else { return }
                try? await Task.sleep(for: .seconds(1.6)) // Cancelled when a newer toast replaces this one.
                guard !Task.isCancelled else { return }
                message = nil
            }
    }
}
