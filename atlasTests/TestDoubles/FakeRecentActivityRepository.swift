import Foundation
@testable import atlas

@MainActor
final class FakeRecentActivityRepository: RecentActivityRepository {
    private(set) var recorded: [(entry: DocumentationEntry, date: Date)] = []
    var shouldFail = false

    func recentActivity(limit: Int) throws -> [RecentActivity] {
        recorded.prefix(limit).map { RecentActivity(entry: $0.entry, lastOpenedAt: $0.date) }
    }

    func recordOpening(of entry: DocumentationEntry, at date: Date) throws {
        if shouldFail { throw DocumentationError.invalidResponse }
        recorded.append((entry, date))
    }

    func clearActivity() throws {
        recorded.removeAll()
    }
}
