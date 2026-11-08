import SwiftUI

struct DetailRelationshipsSection: View {
    let relationships: [TopicGroup]

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.s16) {
            DetailSectionTitle(.detailRelatedTitle)
            ForEach(relationships) { RelatedSection(group: $0) }
        }
    }
}
