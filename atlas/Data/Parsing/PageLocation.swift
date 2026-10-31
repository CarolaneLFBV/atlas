import Foundation

/// Used when a page's URL can't be derived from its normalized path (case-sensitive file names)
/// and for version-pinned downloads that skip unchanged pages without any request.
nonisolated struct PageLocation: Hashable, Sendable {
    let dataURL: URL
    /// An opaque content version (e.g. a git blob SHA); `nil` when the index doesn't provide one.
    let version: String?
}
