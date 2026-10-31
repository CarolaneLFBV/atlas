import Foundation

/// Unrecognized kinds are preserved verbatim.
nonisolated enum SymbolKind: Hashable, Codable, Sendable {
    case structure
    case classType
    case enumeration
    case enumerationCase
    case `protocol`
    case function
    case method
    case property
    case initializer
    case typeAlias
    case macro
    case `operator`
    case associatedType
    case variable
    case other(String)

    /// Maps a DocC `symbolKind` or role heading (e.g. `"struct"`, `"Instance Method"`).
    init(docCIdentifier raw: String) {
        switch raw.lowercased().replacingOccurrences(of: " ", with: "") {
        case "struct", "structure": self = .structure
        case "class": self = .classType
        case "enum", "enumeration": self = .enumeration
        case "case", "enum.case", "enumerationcase": self = .enumerationCase
        case "protocol": self = .protocol
        case "func", "function": self = .function
        case "method", "instancemethod", "typemethod": self = .method
        case "property", "instanceproperty", "typeproperty": self = .property
        case "init", "initializer": self = .initializer
        case "typealias": self = .typeAlias
        case "macro": self = .macro
        case "op", "operator": self = .operator
        case "associatedtype": self = .associatedType
        case "var", "variable", "globalvariable": self = .variable
        default: self = .other(raw)
        }
    }
}
