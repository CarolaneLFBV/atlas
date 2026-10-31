import Foundation

protocol RecentActivityRepository: AnyObject {
    /// Most recent first.
    func recentActivity(limit: Int) throws -> [RecentActivity]
    /// Opening the same entry again updates its timestamp instead of duplicating it.
    func recordOpening(of entry: DocumentationEntry, at date: Date) throws
    func clearActivity() throws
}
