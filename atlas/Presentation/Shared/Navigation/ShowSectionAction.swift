import SwiftUI

/// Moves to a top-level section: a tab on iPhone, a sidebar item on iPad and Mac.
///
/// Lets screens send people elsewhere ("Browse Library", the Library's search field) without
/// knowing the navigation structure.
struct ShowSectionAction {
    let show: (AppSection) -> Void

    func callAsFunction(_ section: AppSection) {
        show(section)
    }
}

extension EnvironmentValues {
    @Entry var showSection = ShowSectionAction { _ in }
}
