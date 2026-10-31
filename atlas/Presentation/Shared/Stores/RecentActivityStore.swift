import Foundation
import Observation
import OSLog

@Observable
final class RecentActivityStore {
    private static let logger = Logger(subsystem: "atlas", category: "History")

    private(set) var items: [RecentActivity] = []

    private let manageActivity: ManageRecentActivityUseCase
    private let limit: Int

    init(manageActivity: ManageRecentActivityUseCase, limit: Int = 30) {
        self.manageActivity = manageActivity
        self.limit = limit
        reload()
    }

    func reload() {
        do {
            items = try manageActivity.recent(limit: limit)
        } catch {
            Self.logger.error("Reading reading history failed: \(error)")
        }
    }

    func clear() {
        do {
            try manageActivity.clear()
        } catch {
            Self.logger.error("Clearing reading history failed: \(error)")
        }
        reload()
    }
}
