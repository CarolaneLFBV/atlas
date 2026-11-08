import SwiftUI

struct DetailLoadedContent: View {
    let detail: DocumentationDetail
    let isFrameworkPage: Bool
    let saveSnippet: (CodeSnippet) -> Void

    var body: some View {
        if detail.isDeprecated {
            DeprecationBanner(notice: detail.deprecationNotice, replacements: detail.replacements)
        }
        if let declaration = detail.declaration {
            DeclarationView(declaration: declaration)
        }
        if isFrameworkPage {
            FrameworkPageContent(detail: detail)
        }
        if detail.permission.allowsProse {
            DetailProseSections(sections: detail.sections, frameworkName: detail.entry.frameworkName, saveSnippet: saveSnippet)
        } else {
            OfficialDocumentationCard(
                url: detail.entry.webURL,
                reason: String(localized: .detailFullTextOnWebsite)
            )
        }
        if !isFrameworkPage, !detail.topics.isEmpty {
            DetailTopicsSection(topics: detail.topics)
        }
        if !detail.relationships.isEmpty {
            DetailRelationshipsSection(relationships: detail.relationships)
        }
        LicenseFooter(permission: detail.permission, webURL: detail.entry.webURL)
    }
}
