import SwiftUI

struct DetailPageHeader: View {
    let state: DocumentationDetailViewModel.State
    let entry: DocumentationEntry
    let isFrameworkPage: Bool
    let reload: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.s16) {
            if case .loaded(let fetched) = state {
                FreshnessNotice(freshness: fetched.freshness, retry: reload)
                if isFrameworkPage {
                    FrameworkHeaderView(detail: fetched.value)
                } else {
                    DetailHeaderView(entry: fetched.value.entry, isDeprecated: fetched.value.isDeprecated)
                }
                if !isFrameworkPage, !fetched.value.availability.isEmpty {
                    AvailabilityView(availability: fetched.value.availability, frameworkName: fetched.value.entry.frameworkName)
                }
            } else {
                DetailHeaderView(entry: entry)
            }
        }
    }
}
