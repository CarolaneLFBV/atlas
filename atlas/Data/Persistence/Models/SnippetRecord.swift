import Foundation
import SwiftData

@Model
final class SnippetRecord {
    @Attribute(.unique) var id: UUID
    var title: String
    var language: String
    var code: String
    /// `nil` for user-authored snippets; otherwise the storage key of the source page.
    var originKey: String?
    var createdAt: Date

    init(id: UUID, title: String, language: String, code: String, originKey: String?, createdAt: Date) {
        self.id = id
        self.title = title
        self.language = language
        self.code = code
        self.originKey = originKey
        self.createdAt = createdAt
    }
}
