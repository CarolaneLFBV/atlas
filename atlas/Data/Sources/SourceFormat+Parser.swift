import Foundation

nonisolated extension SourceFormat {
    var parser: any FormatParser {
        switch self {
        case .docc: DocCFormatParser()
        case .swiftEvolution: SwiftEvolutionFormatParser()
        }
    }
}
