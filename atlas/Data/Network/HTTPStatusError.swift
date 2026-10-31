import Foundation

nonisolated struct HTTPStatusError: Error, Equatable, Sendable {
    let statusCode: Int
}
