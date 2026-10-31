import Foundation

/// Shared with the UI tests, which pass them to `XCUIApplication`.
nonisolated enum LaunchArguments {
    /// Starts with an in-memory store and fixture documentation (Debug builds only), so UI tests are
    /// deterministic and never touch the network or the user's data.
    static let uiTesting = "-atlas-ui-testing"
}
