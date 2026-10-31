import SwiftUI

/// States how current displayed content is, so cached or offline data is never presented as live.
///
/// A copy served because the source couldn't be reached gets the handoff's offline banner
/// (with Retry when the caller can retry); a copy that is simply cached gets a quiet caption.
struct FreshnessNotice: View {
    let freshness: Freshness
    var retry: (() -> Void)?

    var body: some View {
        switch freshness {
        case .fresh:
            EmptyView()
        case .cached(let date):
            Text(.freshnessUpdated(date: date.formatted(.relative(presentation: .named))))
                .font(.atlasCaption)
                .foregroundStyle(AtlasColor.secondaryText)
        case .stale(let date):
            HStack(spacing: Spacing.inline) {
                Circle().fill(AtlasColor.warning).frame(width: 8, height: 8)
                    .accessibilityHidden(true)
                Text(.freshnessOffline(date: date.formatted(.dateTime.month(.abbreviated).day())))
                    .frame(maxWidth: .infinity, alignment: .leading)
                if let retry {
                    Button(.freshnessRetry, action: retry)
                        .fontWeight(.semibold)
                        .buttonStyle(.plain)
                }
            }
            .font(.atlasSecondary)
            .foregroundStyle(AtlasColor.warningText)
            .padding(.horizontal, Spacing.s12)
            .padding(.vertical, Spacing.s8 + 2)
            .background(AtlasColor.warningFill, in: Radius.shape(Radius.field))
            .accessibilityElement(children: .combine)
        }
    }
}

#if DEBUG
#Preview {
    VStack(alignment: .leading) {
        FreshnessNotice(freshness: .cached(fetchedAt: .now.addingTimeInterval(-3_600)))
        FreshnessNotice(freshness: .stale(fetchedAt: .now.addingTimeInterval(-86_400))) {}
    }
    .padding()
}
#endif
