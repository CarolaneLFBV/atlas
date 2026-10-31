import SwiftUI

/// One switch per catalogue category ("Developer Tools"…): hidden categories don't appear in the
/// Library or the sidebar. Their pages stay reachable from search and links.
struct LibrarySectionsSection: View {
    @State private var viewModel: LibraryViewModel
    @AppStorage(SettingsKeys.hiddenCategories) private var hiddenCategories = ""
    @AppStorage(SettingsKeys.turnedOffSources) private var turnedOffSources = ""

    init(viewModel: LibraryViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        Section {
            ForEach(viewModel.allCategoryNames, id: \.self) { name in
                Toggle(name, isOn: isShown(name))
            }
        } header: {
            Text(.settingsLibrarySectionsHeader)
        } footer: {
            Text(.settingsLibrarySectionsFooter)
        }
        .task(id: turnedOffSources) { await viewModel.load() }
    }

    private func isShown(_ name: String) -> Binding<Bool> {
        Binding(
            get: { !StringSetPreference.decode(hiddenCategories).contains(name) },
            set: { hiddenCategories = StringSetPreference.setting(name, included: !$0, in: hiddenCategories) }
        )
    }
}
