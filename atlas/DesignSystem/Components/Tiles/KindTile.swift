import SwiftUI

struct KindTile: View {
    let kind: DocumentationKind
    var frameworkName: String?
    var size: CGFloat = 28
    var style: FrameworkTile.Style = .tinted

    var body: some View {
        MonogramTile(text: Self.letter(for: kind), tint: FrameworkIdentity.of(frameworkName).tint, size: size, style: style)
            .accessibilityLabel(Self.accessibilityName(for: kind))
    }

    static func letter(for kind: DocumentationKind) -> String {
        switch kind {
        case .framework, .collection: "F"
        case .article, .unknown: "A"
        case .tutorial: "T"
        case .sampleCode: "{}"
        case .symbol(let symbol):
            switch symbol {
            case .structure: "S"
            case .classType: "C"
            case .enumeration: "E"
            case .enumerationCase: "c"
            case .protocol: "P"
            case .function: "ƒ"
            case .method: "M"
            case .property, .variable: "V"
            case .initializer: "I"
            case .typeAlias: "T"
            case .macro: "#"
            case .operator: "O"
            case .associatedType: "A"
            case .other: "?"
            }
        }
    }

    static func accessibilityName(for kind: DocumentationKind) -> Text {
        switch kind {
        case .framework: Text(.kindFramework)
        case .article: Text(.kindArticle)
        case .tutorial: Text(.kindTutorial)
        case .sampleCode: Text(.kindSampleCode)
        case .collection: Text(.kindCollection)
        case .unknown: Text(.kindPage)
        case .symbol(let symbol):
            switch symbol {
            case .structure: Text(.kindStructure)
            case .classType: Text(.kindClass)
            case .enumeration: Text(.kindEnumeration)
            case .enumerationCase: Text(.kindEnumerationCase)
            case .protocol: Text(.kindProtocol)
            case .function: Text(.kindFunction)
            case .method: Text(.kindMethod)
            case .property: Text(.kindProperty)
            case .variable: Text(.kindVariable)
            case .initializer: Text(.kindInitializer)
            case .typeAlias: Text(.kindTypeAlias)
            case .macro: Text(.kindMacro)
            case .operator: Text(.kindOperator)
            case .associatedType: Text(.kindAssociatedType)
            case .other(let name): Text(verbatim: name)
            }
        }
    }
}

#if DEBUG
#Preview {
    HStack {
        KindTile(kind: .symbol(.structure), frameworkName: "SwiftUI", size: 36, style: .solid)
        KindTile(kind: .symbol(.initializer), frameworkName: "SwiftUI")
        KindTile(kind: .symbol(.method), frameworkName: "SwiftData")
        KindTile(kind: .article, frameworkName: "The Swift Programming Language")
    }
    .padding()
}
#endif
