import SwiftUI

/// The color and monogram that identify a framework or guide, used only for identity tiles,
/// framework dots and soft gradient tints.
///
/// Well-known names have the identities of the design handoff; others get a stable color from the
/// same palette and a monogram from their initials, so they never change across launches.
nonisolated struct FrameworkIdentity: Hashable, Sendable {
    let tint: Color
    let monogram: String

    static func of(_ name: String?) -> FrameworkIdentity {
        guard let name, !name.isEmpty else { return FrameworkIdentity(tint: neutral, monogram: "?") }
        let key = normalizedKey(name)
        if let curated = curated[key] ?? curatedPrefixMatch(for: key) { return curated }
        return FrameworkIdentity(tint: palette[stableIndex(for: key, count: palette.count)], monogram: monogram(for: name))
    }

    /// Lowercased letters and digits only, so "Core ML" and "CoreML" share an identity.
    static func normalizedKey(_ name: String) -> String {
        name.lowercased().filter { $0.isLetter || $0.isNumber }
    }

    /// A launch-stable index. `Hasher` is randomly seeded per process, so it cannot be used here.
    static func stableIndex(for key: String, count: Int) -> Int {
        var hash: UInt64 = 5381
        for byte in key.utf8 { hash = (hash &* 33) &+ UInt64(byte) }
        return Int(hash % UInt64(count))
    }

    static func monogram(for name: String) -> String {
        let words = name.split(whereSeparator: { !$0.isLetter && !$0.isNumber })
        guard let first = words.first else { return "?" }
        if words.count > 1, let second = words.dropFirst().first?.first, let initial = first.first {
            return String([initial, second]).uppercased()
        }
        return first.prefix(1).uppercased() + first.dropFirst().prefix(1).lowercased()
    }

    /// Catalogue titles can carry a version ("The Swift Programming Language (6.4 beta)"): a curated
    /// key followed only by a version still identifies it. ("FoundationModels" is not "Foundation".)
    private static func curatedPrefixMatch(for key: String) -> FrameworkIdentity? {
        curated.keys
            .filter { key.hasPrefix($0) && key.dropFirst($0.count).first?.isNumber == true }
            .max { $0.count < $1.count }
            .flatMap { curated[$0] }
    }

    // MARK: Values

    private static let neutral = Color(red: 0.43, green: 0.43, blue: 0.45)

    private static func hex(_ value: UInt32) -> Color {
        Color(red: Double((value >> 16) & 0xFF) / 255, green: Double((value >> 8) & 0xFF) / 255, blue: Double(value & 0xFF) / 255)
    }

    /// The handoff's framework hues, used for names without a curated identity.
    private static let palette: [Color] = [0x2F7CF6, 0x2FB38A, 0xE8694A, 0x2451B8, 0x8A5CF6, 0x1FA3B5, 0xD9A21B, 0xE04F8B].map(hex)

    private static let curated: [String: FrameworkIdentity] = [
        "swiftui": .init(tint: hex(0x2F7CF6), monogram: "SU"),
        "swiftdata": .init(tint: hex(0x2FB38A), monogram: "SD"),
        "foundation": .init(tint: hex(0xE8694A), monogram: "Fn"),
        "uikit": .init(tint: hex(0x2451B8), monogram: "UK"),
        "appkit": .init(tint: hex(0x2451B8), monogram: "AK"),
        "coreml": .init(tint: hex(0x8A5CF6), monogram: "ML"),
        "vision": .init(tint: hex(0x1FA3B5), monogram: "Vi"),
        "combine": .init(tint: hex(0xD9A21B), monogram: "Cb"),
        "swiftcharts": .init(tint: hex(0xE04F8B), monogram: "Ch"),
        "charts": .init(tint: hex(0xE04F8B), monogram: "Ch"),
        // Swift guides, in Swift's orange family.
        "swift": .init(tint: hex(0xF05138), monogram: "Sw"),
        "theswiftprogramminglanguage": .init(tint: hex(0xF05138), monogram: "Sw"),
        "migratingtoswift6": .init(tint: hex(0xE8694A), monogram: "M6"),
        // The migration guide's DocC module, named on its pages.
        "swiftconcurrency": .init(tint: hex(0xE8694A), monogram: "M6"),
        "swiftevolution": .init(tint: hex(0x8A5CF6), monogram: "SE"),
    ]
}
