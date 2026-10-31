import Foundation

nonisolated struct Fetched<Value: Sendable>: Sendable {
    let value: Value
    let freshness: Freshness
}
