import Foundation

/// Revalidation uses conditional requests, so an unchanged resource costs a `304` and no download.
/// There is no background polling: resources are only revalidated when the user needs them.
nonisolated struct CachePolicy: Sendable {
    var catalogueMaxAge: Duration = .seconds(24 * 60 * 60)
    var pageMaxAge: Duration = .seconds(7 * 24 * 60 * 60)
    var searchIndexMaxAge: Duration = .seconds(7 * 24 * 60 * 60)

    static let standard = CachePolicy()

    func isFresh(fetchedAt: Date, maxAge: Duration, now: Date) -> Bool {
        now.timeIntervalSince(fetchedAt) < TimeInterval(maxAge.components.seconds)
    }
}
