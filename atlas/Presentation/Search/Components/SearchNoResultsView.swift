import SwiftUI

struct SearchNoResultsView: View {
    let query: String
    @AppStorage(SettingsKeys.appleContentFetchingEnabled) private var appleContentFetchingEnabled = false

    var body: some View {
        ContentUnavailableView {
            Label(.searchNoResultsTitle, systemImage: AtlasSymbol.search)
        } description: {
            if appleContentFetchingEnabled {
                Text(.searchNoResultsAppleMessage(query: query))
            } else {
                Text(.searchNoResultsMessage(query: query))
            }
        }
    }
}
