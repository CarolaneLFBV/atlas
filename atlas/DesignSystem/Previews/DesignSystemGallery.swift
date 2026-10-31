import SwiftUI

// Preview-only code: excluded from Release builds.
#if DEBUG
/// All content here is preview fixture text, not documentation.
private struct DesignSystemGallery: View {
    private let sampleEntry = DocumentationEntry(
        id: DocumentationID(sourceID: DocumentationSourceID(rawValue: "preview"), path: "/fixture/navigationstack"),
        title: "NavigationStack",
        kind: .symbol(.structure),
        frameworkName: "SwiftUI",
        abstract: "Preview fixture abstract."
    )

    private let colors: [(String, Color)] = [
        ("background", AtlasColor.background), ("secondary", AtlasColor.secondaryBackground),
        ("surface", AtlasColor.surface), ("code", AtlasColor.codeBackground),
        ("fill", AtlasColor.fill), ("selection", AtlasColor.selection),
        ("accent", AtlasColor.accent), ("success", AtlasColor.success),
        ("warning", AtlasColor.warning), ("danger", AtlasColor.danger),
    ]

    private let frameworks = ["SwiftUI", "SwiftData", "Foundation", "UIKit", "Core ML", "Vision", "Combine", "Swift Charts", "Swift Evolution"]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.section) {
                typography
                palette
                identities
                cards
                controls
                DocumentationRow(entry: sampleEntry).cardSurface(padding: Spacing.s12)
                CodeSnippetView(
                    code: "struct ContentView: View {\n    var body: some View {\n        Text(\"Fixture\") // 42\n    }\n}",
                    title: "ContentView.swift",
                    frameworkName: "Foundation"
                )
                SearchScopeNotice(capability: .metadata)
            }
            .padding(Spacing.contentMargin)
            .readableWidth()
        }
        .background(AtlasColor.background)
        .toastHost()
    }

    private var typography: some View {
        VStack(alignment: .leading, spacing: Spacing.inline) {
            Text("Library").font(.atlasScreenTitle)
            Text("NavigationStack").font(.atlasDocumentTitle)
            Text("Overview").font(.atlasSectionTitle)
            Text("All frameworks").font(.atlasSectionHeading)
            Text("A view that displays a root view and enables you to present additional views.").font(.atlasAbstract)
            Text("Body text for documentation prose.").font(.atlasBody)
            Text("Row title").font(.atlasRowTitle)
            Text("Row subtitle").font(.atlasSecondary).foregroundStyle(AtlasColor.secondaryText)
            Text("Declaration").atlasEyebrow().foregroundStyle(AtlasColor.secondaryText)
            Text(verbatim: "struct NavigationStack<Data, Root>").font(.atlasDeclaration)
            Text(verbatim: "1,284 symbols · iOS 16.0+").font(.atlasMonoMeta).foregroundStyle(AtlasColor.secondaryText)
        }
    }

    private var palette: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 64), spacing: Spacing.inline)], spacing: Spacing.inline) {
            ForEach(colors, id: \.0) { name, color in
                VStack(spacing: Spacing.tight) {
                    Radius.shape(Radius.list).fill(color).frame(height: 44)
                        .overlay(Radius.shape(Radius.list).strokeBorder(AtlasColor.separator, lineWidth: Sizing.hairline))
                    Text(verbatim: name).font(.caption2).foregroundStyle(AtlasColor.secondaryText)
                }
            }
        }
    }

    private var identities: some View {
        VStack(alignment: .leading, spacing: Spacing.stack) {
            HStack(spacing: Spacing.inline) {
                ForEach(frameworks, id: \.self) { FrameworkTile($0, size: 30, style: .solid) }
            }
            HStack(spacing: Spacing.inline) {
                ForEach(frameworks, id: \.self) { FrameworkTile($0, size: 30) }
            }
            HStack(spacing: Spacing.s16) {
                KindTile(kind: .symbol(.structure), frameworkName: "SwiftUI", size: 36, style: .solid)
                KindTile(kind: .symbol(.initializer), frameworkName: "SwiftUI")
                KindTile(kind: .symbol(.classType), frameworkName: "SwiftData")
                KindTile(kind: .article, frameworkName: "Foundation")
                FrameworkMarker(frameworkName: "SwiftUI").font(.atlasCaption)
            }
        }
    }

    private var cards: some View {
        VStack(spacing: Spacing.s12) {
            FeaturedHeroCard(title: "SwiftUI", subtitle: "Preview fixture")
            HStack(spacing: Spacing.s12) {
                FeaturedCard(title: "SwiftData", subtitle: "Preview fixture")
                FeaturedCard(title: "Vision", subtitle: "Preview fixture")
            }
            HStack(spacing: Spacing.s12) {
                FrameworkGridCell(title: "Foundation", subtitle: "Preview fixture")
                FrameworkGridCell(title: "Combine")
            }
        }
    }

    private var controls: some View {
        VStack(alignment: .leading, spacing: Spacing.stack) {
            HStack {
                FilterChip(title: "All", count: 12, isSelected: true) {}
                FilterChip(title: "SwiftUI", frameworkName: "SwiftUI", isSelected: false) {}
            }
            HStack {
                StatusBadge(text: "iOS 16.0+")
                StatusBadge(text: "Beta", style: .beta)
                DeprecatedBadge()
                CopyButton(text: "fixture")
                CopyButton(text: "fixture", style: .icon)
            }
            ToastView(message: "Copied to clipboard")
        }
    }
}

#Preview("Light") {
    DesignSystemGallery()
}

#Preview("Dark, accessibility size") {
    DesignSystemGallery()
        .preferredColorScheme(.dark)
        .dynamicTypeSize(.accessibility2)
}
#endif
