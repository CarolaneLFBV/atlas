import SwiftUI

struct SettingsView: View {
    @AppStorage(SettingsKeys.appleContentFetchingEnabled) private var appleContentFetchingEnabled = false
    @Environment(RecentActivityStore.self) private var recentActivity
    @Environment(AppDependencies.self) private var dependencies
    @State private var isConfirmingClearHistory = false

    var body: some View {
        Form {
            SourceTogglesSection(sources: dependencies.documentationRepository.sourceStatuses.filter { $0.id != .apple })

            Section {
                Toggle(.settingsAppleToggle, isOn: $appleContentFetchingEnabled)
                    .accessibilityIdentifier("settings.appleContentFetching")
            } header: {
                Text(.settingsAppleHeader)
            } footer: {
                Text(.settingsAppleFooter)
            }

            LibrarySectionsSection(viewModel: LibraryViewModel(loadCatalogue: dependencies.loadCatalogue))

            OfflineContentSection()

            Section {
                Button(.settingsClearHistoryButton, role: .destructive) {
                    isConfirmingClearHistory = true
                }
                .disabled(recentActivity.items.isEmpty)
            } header: {
                Text(.settingsPrivacyHeader)
            } footer: {
                Text(.settingsPrivacyFooter)
            }

            Section(.settingsAboutHeader) {
                if let terms = URL(string: "https://www.apple.com/legal/internet-services/terms/site.html") {
                    Link(.settingsAppleTermsLink, destination: terms)
                }
                LabeledContent(.settingsVersion, value: Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "—")
            }
        }
        .navigationTitle(.sectionSettings)
        .confirmationDialog(.settingsClearHistoryConfirmTitle, isPresented: $isConfirmingClearHistory, titleVisibility: .visible) {
            Button(.settingsClearHistoryConfirmButton, role: .destructive) { recentActivity.clear() }
        } message: {
            Text(.settingsClearHistoryConfirmMessage)
        }
    }
}

#if DEBUG
#Preview {
    NavigationStack { SettingsView() }
        .previewEnvironment()
}
#endif
