import Foundation

struct ManageRecentActivityUseCase {
    let repository: any RecentActivityRepository

    /// Most recent first.
    func recent(limit: Int = 20) throws -> [RecentActivity] {
        try repository.recentActivity(limit: limit)
    }

    func clear() throws {
        try repository.clearActivity()
    }
}
