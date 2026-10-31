import Foundation

nonisolated enum SourceFormat: Hashable, Sendable {
    case docc
    case swiftEvolution

    /// Whether the format's index declares each page's exact data URL (needed when URLs can't be
    /// derived from normalized, lowercased paths).
    var declaresPageLocations: Bool {
        switch self {
        case .docc: false
        case .swiftEvolution: true
        }
    }
}
