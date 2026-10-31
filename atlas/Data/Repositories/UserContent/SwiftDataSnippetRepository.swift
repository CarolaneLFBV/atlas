import Foundation
import SwiftData

final class SwiftDataSnippetRepository: SnippetRepository {
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func snippets() throws -> [CodeSnippet] {
        let descriptor = FetchDescriptor<SnippetRecord>(sortBy: [SortDescriptor(\.createdAt, order: .reverse)])
        return try context.fetch(descriptor).map(Self.snippet(from:))
    }

    func save(_ snippet: CodeSnippet) throws {
        let originKey = Self.originKey(for: snippet.origin)
        if let existing = try record(for: snippet.id) {
            existing.title = snippet.title
            existing.language = snippet.language
            existing.code = snippet.code
            existing.originKey = originKey
        } else {
            context.insert(SnippetRecord(
                id: snippet.id, title: snippet.title, language: snippet.language,
                code: snippet.code, originKey: originKey, createdAt: snippet.createdAt
            ))
        }
        try context.save()
    }

    func deleteSnippet(_ id: UUID) throws {
        guard let existing = try record(for: id) else { return }
        context.delete(existing)
        try context.save()
    }

    private func record(for id: UUID) throws -> SnippetRecord? {
        var descriptor = FetchDescriptor<SnippetRecord>(predicate: #Predicate { $0.id == id })
        descriptor.fetchLimit = 1
        return try context.fetch(descriptor).first
    }

    // MARK: Mapping

    private static func snippet(from record: SnippetRecord) -> CodeSnippet {
        let origin: CodeSnippet.Origin = record.originKey
            .flatMap(DocumentationID.init(storageKey:))
            .map { .documentation($0) } ?? .userAuthored
        return CodeSnippet(
            id: record.id, title: record.title, language: record.language,
            code: record.code, origin: origin, createdAt: record.createdAt
        )
    }

    private static func originKey(for origin: CodeSnippet.Origin) -> String? {
        switch origin {
        case .userAuthored: nil
        case .documentation(let id): id.storageKey
        }
    }
}
