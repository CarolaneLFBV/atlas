import Foundation

/// Prose is rendered as `AttributedString`, whose links are URLs; a reference becomes
/// `atlas-doc://page?key=<storage key>&title=<title>`, and the page's `openURL` handler turns it
/// back into an entry to open. These URLs never leave the app.
nonisolated enum DocumentationReferenceURL {
    static let scheme = "atlas-doc"

    static func url(for id: DocumentationID, title: String) -> URL? {
        var components = URLComponents()
        components.scheme = scheme
        components.host = "page"
        components.queryItems = [URLQueryItem(name: "key", value: id.storageKey), URLQueryItem(name: "title", value: title)]
        return components.url
    }

    static func entry(from url: URL) -> DocumentationEntry? {
        guard url.scheme == scheme,
              let items = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems,
              let key = items.first(where: { $0.name == "key" })?.value,
              let id = DocumentationID(storageKey: key)
        else { return nil }
        let title = items.first(where: { $0.name == "title" })?.value ?? id.path
        // The kind is unknown until the page loads; the detail screen shows the loaded entry.
        return DocumentationEntry(id: id, title: title, kind: .unknown)
    }
}
