import Foundation
import Testing
@testable import atlas

@MainActor
@Suite("GetDocumentationDetailUseCase")
struct GetDocumentationDetailUseCaseTests {
    @Test("Opening a page records it in recent activity")
    func recordsActivity() async throws {
        let entry = Fixture.entry("View")
        let activity = FakeRecentActivityRepository()
        let date = Date(timeIntervalSince1970: 1_000)
        let useCase = GetDocumentationDetailUseCase(
            repository: FakeDocumentationRepository(detail: Fixture.detail(for: entry)),
            activity: activity,
            now: { date }
        )

        let result = try await useCase.execute(id: entry.id)

        #expect(result.value.entry == entry)
        #expect(activity.recorded.map(\.entry) == [entry])
        #expect(activity.recorded.first?.date == date)
    }

    @Test("A history failure does not prevent reading")
    func survivesActivityFailure() async throws {
        let entry = Fixture.entry("View")
        let activity = FakeRecentActivityRepository()
        activity.shouldFail = true
        let useCase = GetDocumentationDetailUseCase(
            repository: FakeDocumentationRepository(detail: Fixture.detail(for: entry)),
            activity: activity
        )

        let result = try await useCase.execute(id: entry.id)

        #expect(result.value.id == entry.id)
    }

    @Test("Repository errors are propagated")
    func propagatesErrors() async {
        let id = Fixture.id("/missing")
        let useCase = GetDocumentationDetailUseCase(
            repository: FakeDocumentationRepository(),
            activity: FakeRecentActivityRepository()
        )
        await #expect(throws: DocumentationError.notFound(id)) {
            try await useCase.execute(id: id)
        }
    }
}
