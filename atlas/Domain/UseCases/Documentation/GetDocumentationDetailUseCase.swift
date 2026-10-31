import Foundation

/// Loads a page and records it in the reading history.
struct GetDocumentationDetailUseCase {
    let repository: any DocumentationRepository
    let activity: any RecentActivityRepository
    var now: @Sendable () -> Date = { .now }

    func execute(id: DocumentationID) async throws -> Fetched<DocumentationDetail> {
        let detail = try await repository.detail(for: id)
        // History is best effort: failing to record it must not prevent reading.
        try? activity.recordOpening(of: detail.value.entry, at: now())
        return detail
    }
}
