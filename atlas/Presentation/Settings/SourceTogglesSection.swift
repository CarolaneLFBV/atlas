import SwiftUI

/// One switch per documentation source: a source turned off is never contacted, listed or searched.
struct SourceTogglesSection: View {
    let sources: [DocumentationSourceStatus]

    @AppStorage(SettingsKeys.turnedOffSources) private var turnedOffSources = ""

    var body: some View {
        if !sources.isEmpty {
            Section {
                ForEach(sources) { source in
                    Toggle(source.displayName, isOn: isOn(source.id))
                }
            } header: {
                Text(.settingsSourcesHeader)
            } footer: {
                Text(.settingsSourcesFooter)
            }
        }
    }

    private func isOn(_ id: DocumentationSourceID) -> Binding<Bool> {
        Binding(
            get: { !StringSetPreference.decode(turnedOffSources).contains(id.rawValue) },
            set: { turnedOffSources = StringSetPreference.setting(id.rawValue, included: !$0, in: turnedOffSources) }
        )
    }
}
