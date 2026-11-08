import SwiftUI

struct TopicEntriesList: View {
    let entries: [DocumentationEntry]
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    var body: some View {
        if horizontalSizeClass == .regular {
            LazyVGrid(columns: [GridItem(.flexible(), spacing: Spacing.s12), GridItem(.flexible())], spacing: Spacing.s12) {
                ForEach(entries) { entry in
                    TopicRow(entry: entry)
                        .padding(.horizontal, Spacing.s12)
                        .frame(maxHeight: .infinity, alignment: .top)
                        .cardSurface(padding: 0, fill: AtlasColor.background)
                }
            }
            .padding(.top, Spacing.s12)
        } else {
            // Lazy: some groups are long (Swift Evolution lists hundreds of proposals).
            LazyVStack(spacing: 0) {
                ForEach(entries) { entry in
                    TopicRow(entry: entry)
                    HairlineDivider()
                }
            }
        }
    }
}
