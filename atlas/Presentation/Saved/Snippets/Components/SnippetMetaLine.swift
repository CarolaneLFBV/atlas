import SwiftUI

struct SnippetMetaLine: View {
    let snippet: CodeSnippet

    var body: some View {
        Text(.snippetMetaLine(origin: origin, date: snippet.createdAt.formatted(.relative(presentation: .named))))
            .font(.atlasCaption)
            .foregroundStyle(AtlasColor.secondaryText)
            .lineLimit(1)
    }

    private var origin: String {
        switch snippet.origin {
        case .userAuthored: String(localized: .snippetOriginUserAuthored)
        case .documentation: String(localized: .snippetOriginDocumentation)
        }
    }

    static func header(for snippet: CodeSnippet) -> String {
        let lines = snippet.code.split(separator: "\n", omittingEmptySubsequences: false).count
        return String(localized: .snippetHeader(language: snippet.language.capitalized, lines: lines))
    }
}
