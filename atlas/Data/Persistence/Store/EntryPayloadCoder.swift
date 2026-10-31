import Foundation

/// Encodes entries in the current stored format and decodes every format ever written.
nonisolated enum EntryPayloadCoder {
    enum DecodingError: Error, CustomStringConvertible {
        /// Written by a newer version of the app; kept on disk, skipped for now.
        case unsupportedVersion(Int)

        var description: String {
            switch self {
            case .unsupportedVersion(let version): "Stored entry version \(version) is newer than this app supports"
            }
        }
    }

    struct Decoded {
        let entry: DocumentationEntry
        let needsMigration: Bool
    }

    static func encode(_ entry: DocumentationEntry) throws -> Data {
        try JSONEncoder().encode(StoredEntry(entry))
    }

    static func decode(_ data: Data) throws -> Decoded {
        let version = try JSONDecoder().decode(VersionProbe.self, from: data).version
        switch version {
        case nil:
            // Version 0: payloads written before the stored format existed (up to October 2026)
            // used `DocumentationEntry`'s own Codable shape. They are rewritten on first read.
            return Decoded(entry: try JSONDecoder().decode(DocumentationEntry.self, from: data), needsMigration: true)
        case let version? where version <= StoredEntry.currentVersion:
            return Decoded(entry: try JSONDecoder().decode(StoredEntry.self, from: data).entry, needsMigration: false)
        case let version?:
            throw DecodingError.unsupportedVersion(version)
        }
    }

    private struct VersionProbe: Decodable {
        let version: Int?
    }
}
