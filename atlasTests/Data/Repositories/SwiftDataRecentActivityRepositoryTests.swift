import Foundation
import SwiftData
import Testing
@testable import atlas

@MainActor
@Suite("SwiftDataRecentActivityRepository")
struct SwiftDataRecentActivityRepositoryTests {
    let container: ModelContainer

    init() throws {
        container = try PersistenceStore.makeContainer(inMemory: true)
    }

    @Test("Reopening an entry updates its timestamp instead of duplicating it")
    func deduplicates() throws {
        let repository = SwiftDataRecentActivityRepository(context: container.mainContext)
        try repository.recordOpening(of: Fixture.entry("A"), at: Date(timeIntervalSince1970: 1))
        try repository.recordOpening(of: Fixture.entry("B"), at: Date(timeIntervalSince1970: 2))
        try repository.recordOpening(of: Fixture.entry("A"), at: Date(timeIntervalSince1970: 3))

        let titles = try repository.recentActivity(limit: 10).map(\.entry.title)
        #expect(titles == ["A", "B"])
    }

    @Test("History is capped to the maximum number of items")
    func capsHistory() throws {
        let repository = SwiftDataRecentActivityRepository(context: container.mainContext, maximumItems: 3)
        for index in 0..<5 {
            try repository.recordOpening(of: Fixture.entry("E\(index)"), at: Date(timeIntervalSince1970: Double(index)))
        }

        let titles = try repository.recentActivity(limit: 10).map(\.entry.title)
        #expect(titles == ["E4", "E3", "E2"])
    }

    @Test("Clearing removes all history")
    func clears() throws {
        let repository = SwiftDataRecentActivityRepository(context: container.mainContext)
        try repository.recordOpening(of: Fixture.entry("A"), at: .now)
        #expect(try repository.recentActivity(limit: 10).count == 1)

        try repository.clearActivity()

        #expect(try repository.recentActivity(limit: 10).isEmpty)
    }
}
