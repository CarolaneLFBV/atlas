import Foundation

/// Apple's Website Terms of Use don't permit reproducing site content or automated access without
/// written consent, so this source is disabled unless the user turns it on for personal use.
/// When enabled, requests are made only in response to the user opening the Library or a page.
/// See docs/DocumentationSources.md.
nonisolated struct AppleDeveloperDocumentationSource: DocumentationSource {
    private static let site = URL(string: "https://developer.apple.com")

    let id = DocumentationSourceID.apple
    let displayName = "Apple Developer Documentation"
    let catalogueFormat = CatalogueFormat.technologies
    let searchIndexURL: URL? = nil
    let defaultFrameworkName: String? = nil
    /// Never: bulk downloading would be the automated copying Apple's terms prohibit.
    let allowsOfflineDownload = false

    let permission = RenderingPermission.fullContent(ContentLicense(
        name: "Apple Website Terms of Use",
        url: URL(string: "https://www.apple.com/legal/internet-services/terms/site.html"),
        attribution: "© Apple Inc. Shown for your personal reference — the official page is on developer.apple.com."
    ))

    /// Read on every access so changing the setting takes effect immediately.
    private let isEnabledProvider: @Sendable () -> Bool

    init(isEnabled: @escaping @Sendable () -> Bool) {
        self.isEnabledProvider = isEnabled
    }

    var isEnabled: Bool { isEnabledProvider() }

    var catalogueURL: URL? {
        pageDataURL(forPath: "/documentation/technologies")
    }

    /// `/documentation/swiftui` → `https://developer.apple.com/tutorials/data/index/swiftui`.
    /// Loaded once per framework when the user opens it, so its whole API becomes searchable by name.
    func frameworkIndexURL(forFrameworkPath path: String) -> URL? {
        let components = path.split(separator: "/")
        guard components.count == 2, components[0] == "documentation" else { return nil }
        return Self.site?.appending(path: "tutorials/data/index").appending(path: String(components[1]))
    }

    func pageDataURL(forPath path: String) -> URL? {
        Self.site?.appending(path: "tutorials/data").appending(path: path + ".json")
    }

    func webURL(forPath path: String) -> URL? {
        Self.site?.appending(path: path)
    }
}
