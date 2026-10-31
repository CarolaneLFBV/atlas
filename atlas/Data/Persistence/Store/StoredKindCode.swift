import Foundation

/// Stable string codes for page kinds in stored entries ("framework", "symbol.structure",
/// "symbol.other:Subscript"). Codes are part of the stored format: never rename one.
nonisolated enum StoredKindCode {
    static func code(for kind: DocumentationKind) -> String {
        switch kind {
        case .framework: "framework"
        case .article: "article"
        case .tutorial: "tutorial"
        case .sampleCode: "sampleCode"
        case .collection: "collection"
        case .unknown: "unknown"
        case .symbol(let symbol): "symbol." + code(for: symbol)
        }
    }

    /// Unknown codes (written by a newer version) read as `.unknown` rather than failing.
    static func kind(for code: String) -> DocumentationKind {
        switch code {
        case "framework": .framework
        case "article": .article
        case "tutorial": .tutorial
        case "sampleCode": .sampleCode
        case "collection": .collection
        case let code where code.hasPrefix("symbol."): .symbol(symbol(for: String(code.dropFirst("symbol.".count))))
        default: .unknown
        }
    }

    private static func code(for symbol: SymbolKind) -> String {
        switch symbol {
        case .structure: "structure"
        case .classType: "class"
        case .enumeration: "enumeration"
        case .enumerationCase: "enumerationCase"
        case .protocol: "protocol"
        case .function: "function"
        case .method: "method"
        case .property: "property"
        case .initializer: "initializer"
        case .typeAlias: "typeAlias"
        case .macro: "macro"
        case .operator: "operator"
        case .associatedType: "associatedType"
        case .variable: "variable"
        case .other(let name): "other:" + name
        }
    }

    private static func symbol(for code: String) -> SymbolKind {
        switch code {
        case "structure": .structure
        case "class": .classType
        case "enumeration": .enumeration
        case "enumerationCase": .enumerationCase
        case "protocol": .protocol
        case "function": .function
        case "method": .method
        case "property": .property
        case "initializer": .initializer
        case "typeAlias": .typeAlias
        case "macro": .macro
        case "operator": .operator
        case "associatedType": .associatedType
        case "variable": .variable
        case let code where code.hasPrefix("other:"): .other(String(code.dropFirst("other:".count)))
        default: .other(code)
        }
    }
}
