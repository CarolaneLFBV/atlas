import SwiftUI

/// Provided by `toastHost()` on a root view; components call it without knowing where the toast is drawn.
struct ToastAction {
    let show: (LocalizedStringResource) -> Void

    func callAsFunction(_ message: LocalizedStringResource) {
        show(message)
    }

    /// Used when no host is installed (e.g. in isolated previews): does nothing.
    static let none = ToastAction { _ in }
}

extension EnvironmentValues {
    @Entry var showToast: ToastAction = .none
}

extension View {
    /// Draws toasts requested by descendants through `showToast`, sliding them in from the bottom.
    func toastHost() -> some View {
        modifier(ToastHostModifier())
    }
}
