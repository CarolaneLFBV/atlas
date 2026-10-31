import Foundation

nonisolated struct SourceRegistry: Sendable {
    let sources: [any DocumentationSource]
    /// Sources the user turned off in Settings: never contacted, listed or searched.
    var isTurnedOffByUser: @Sendable (DocumentationSourceID) -> Bool = { _ in false }

    var enabledSources: [any DocumentationSource] { sources.filter(isEnabled) }

    var enabledSourceIDs: Set<DocumentationSourceID> { Set(enabledSources.map(\.id)) }

    var downloadableSources: [any DocumentationSource] { enabledSources.filter(\.allowsOfflineDownload) }

    var statuses: [DocumentationSourceStatus] {
        sources.map {
            DocumentationSourceStatus(
                id: $0.id, displayName: $0.displayName,
                isEnabled: isEnabled($0), isTurnedOffByUser: isTurnedOffByUser($0.id)
            )
        }
    }

    private func isEnabled(_ source: any DocumentationSource) -> Bool {
        source.isEnabled && !isTurnedOffByUser(source.id)
    }

    func source(for id: DocumentationSourceID) throws -> any DocumentationSource {
        guard let source = sources.first(where: { $0.id == id }) else {
            throw DocumentationError.unknownSource(id)
        }
        return source
    }

    /// - Throws: `unknownSource` or `sourceDisabled`.
    func enabledSource(for id: DocumentationSourceID) throws -> any DocumentationSource {
        let source = try source(for: id)
        guard isEnabled(source) else { throw DocumentationError.sourceDisabled(id) }
        return source
    }
}
