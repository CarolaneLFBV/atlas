import Foundation
@testable import atlas

nonisolated struct TestDocumentationSource: DocumentationSource {
    var id = DocumentationSourceID(rawValue: "test")
    var displayName = "Test Source"
    var permission = RenderingPermission.fullContent(ContentLicense(name: "Test License", url: nil, attribution: "Test"))
    var isEnabled = true
    var catalogueFormat = CatalogueFormat.rootPage(category: "Test Category")
    var searchIndexURL: URL?
    var defaultFrameworkName: String? = "TestKit"
    var allowsOfflineDownload = true
    /// When set, `/documentation/<name>` framework pages have an index at `<base>/<name>`.
    var frameworkIndexBase: URL?

    private var base: URL? { URL(string: "https://docs.example.com/\(id.rawValue)") }

    var catalogueURL: URL? { pageDataURL(forPath: "/documentation/root") }

    func frameworkIndexURL(forFrameworkPath path: String) -> URL? {
        guard let frameworkIndexBase, let name = path.split(separator: "/").last else { return nil }
        return frameworkIndexBase.appending(path: String(name))
    }

    func pageDataURL(forPath path: String) -> URL? {
        base?.appending(path: "data").appending(path: path + ".json")
    }

    func webURL(forPath path: String) -> URL? {
        base?.appending(path: path)
    }
}
