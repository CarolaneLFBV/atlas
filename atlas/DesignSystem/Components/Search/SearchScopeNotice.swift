import SwiftUI

/// States plainly what search covers, so metadata search is never presented as full-text search.
///
/// Search input itself uses the native `.searchable` modifier rather than a custom field,
/// which keeps keyboard shortcuts, dictation, tokens and toolbar placement native on every platform.
struct SearchScopeNotice: View {
    let capability: SearchCapability

    var body: some View {
        Label {
            if capability.includesFullText {
                Text(.searchScopeNoticeFullText(sources: capability.fullTextSourceNames.formatted(.list(type: .and))))
            } else {
                Text(.searchScopeNoticeMetadata)
            }
        } icon: {
            Image(systemName: "info.circle")
        }
        .font(.atlasCaption)
        .foregroundStyle(.secondary)
        .accessibilityIdentifier("search.scopeNotice")
    }
}

#if DEBUG
#Preview {
    VStack(alignment: .leading) {
        SearchScopeNotice(capability: .metadata)
        SearchScopeNotice(capability: SearchCapability(fullTextSourceNames: ["Preview Guide"]))
    }
    .padding()
}
#endif
