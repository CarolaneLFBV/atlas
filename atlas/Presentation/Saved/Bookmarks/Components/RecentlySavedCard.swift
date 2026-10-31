import SwiftUI

struct RecentlySavedCard: View {
    let bookmark: Bookmark

    @Environment(\.openDocumentation) private var openDocumentation

    private var identity: FrameworkIdentity { .of(bookmark.entry.frameworkName) }

    var body: some View {
        Button {
            openDocumentation(bookmark.entry)
        } label: {
            VStack(alignment: .leading, spacing: 2) {
                HStack(alignment: .top) {
                    KindTile(kind: bookmark.entry.kind, frameworkName: bookmark.entry.frameworkName, size: 26, style: .solid)
                    Spacer()
                    Image(systemName: AtlasSymbol.bookmarkFilled)
                        .foregroundStyle(AtlasColor.accent)
                        .accessibilityHidden(true)
                }
                Spacer(minLength: Spacing.s16)
                Text(bookmark.entry.title)
                    .font(.subheadline.bold())
                    .foregroundStyle(AtlasColor.primaryText)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                Text(subtitle)
                    .font(.atlasCaption)
                    .foregroundStyle(AtlasColor.secondaryText)
                    .lineLimit(1)
            }
            .padding(Spacing.s12 + 2)
            .frame(maxWidth: .infinity, minHeight: 124, maxHeight: .infinity, alignment: .leading)
            .background(identity.featuredGradient)
            .background(AtlasColor.surface)
            .overlay(Radius.shape(Radius.card).strokeBorder(identity.ring, lineWidth: Sizing.hairline))
            .clipShape(Radius.shape(Radius.card))
            .contentShape(Radius.shape(Radius.card))
        }
        .buttonStyle(.plain)
        .documentationContextMenu(for: bookmark.entry)
        .accessibilityElement(children: .combine)
    }

    private var subtitle: String {
        let date = bookmark.createdAt.formatted(.relative(presentation: .named))
        guard let framework = bookmark.entry.frameworkName else { return date }
        return String(localized: .bookmarksCardSubtitle(framework: framework, date: date))
    }
}
