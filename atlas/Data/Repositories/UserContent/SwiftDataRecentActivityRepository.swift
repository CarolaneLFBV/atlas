import Foundation
import OSLog
import SwiftData

final class SwiftDataRecentActivityRepository: RecentActivityRepository {
    private static let logger = Logger(subsystem: "atlas", category: "History")

    private let context: ModelContext
    private let maximumItems: Int

    init(context: ModelContext, maximumItems: Int = 100) {
        self.context = context
        self.maximumItems = maximumItems
    }

    func recentActivity(limit: Int) throws -> [RecentActivity] {
        var descriptor = FetchDescriptor<RecentActivityRecord>(sortBy: [SortDescriptor(\.lastOpenedAt, order: .reverse)])
        descriptor.fetchLimit = limit
        var migrated = false
        let items = try context.fetch(descriptor).compactMap { record -> RecentActivity? in
            do {
                let decoded = try EntryPayloadCoder.decode(record.entryPayload)
                if decoded.needsMigration {
                    record.entryPayload = try EntryPayloadCoder.encode(decoded.entry)
                    migrated = true
                }
                return RecentActivity(entry: decoded.entry, lastOpenedAt: record.lastOpenedAt)
            } catch {
                Self.logger.error("Skipping unreadable history item \(record.key, privacy: .public): \(error)")
                return nil
            }
        }
        if migrated { try context.save() }
        return items
    }

    func recordOpening(of entry: DocumentationEntry, at date: Date) throws {
        let key = entry.id.storageKey
        let payload = try EntryPayloadCoder.encode(entry)
        var descriptor = FetchDescriptor<RecentActivityRecord>(predicate: #Predicate { $0.key == key })
        descriptor.fetchLimit = 1
        if let existing = try context.fetch(descriptor).first {
            existing.lastOpenedAt = date
            existing.entryPayload = payload
        } else {
            context.insert(RecentActivityRecord(key: key, lastOpenedAt: date, entryPayload: payload))
        }
        try context.save()
        try trimHistory()
    }

    func clearActivity() throws {
        try context.delete(model: RecentActivityRecord.self)
        try context.save()
    }

    /// Trimming is done in memory on saved records: `fetchOffset` is not reliably applied to
    /// unsaved changes, which previously caused the whole history to be deleted.
    private func trimHistory() throws {
        let descriptor = FetchDescriptor<RecentActivityRecord>(sortBy: [SortDescriptor(\.lastOpenedAt, order: .reverse)])
        let overflow = try context.fetch(descriptor).dropFirst(maximumItems)
        guard !overflow.isEmpty else { return }
        overflow.forEach(context.delete)
        try context.save()
    }
}
