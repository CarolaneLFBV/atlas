import Foundation
import Observation

/// On iPhone each tab owns a navigator and pages are pushed onto `path`.
/// On iPad and Mac the split view's detail column owns one: picking a page in the content column
/// replaces `root`, and following a link inside the detail pushes onto `path`.
@Observable
final class DocumentationNavigator {
    var root: DocumentationEntry?
    var path: [DocumentationEntry] = []

    func push(_ entry: DocumentationEntry) {
        path.append(entry)
    }

    func replaceRoot(with entry: DocumentationEntry) {
        root = entry
        path.removeAll()
    }
}
