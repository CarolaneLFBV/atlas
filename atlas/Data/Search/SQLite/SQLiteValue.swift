import Foundation

nonisolated enum SQLiteValue: Sendable {
    case text(String)
    case blob(Data)
    case integer(Int)
    case real(Double)
}
