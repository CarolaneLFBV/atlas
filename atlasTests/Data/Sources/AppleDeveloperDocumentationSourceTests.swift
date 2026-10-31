import Foundation
import Testing
@testable import atlas

@Suite("AppleDeveloperDocumentationSource")
struct AppleDeveloperDocumentationSourceTests {
    let source = AppleDeveloperDocumentationSource(isEnabled: { true })

    @Test("Framework pages map to their navigator index")
    func frameworkIndexURL() {
        #expect(source.frameworkIndexURL(forFrameworkPath: "/documentation/swiftui")?.absoluteString
            == "https://developer.apple.com/tutorials/data/index/swiftui")
    }

    @Test("Pages that aren't frameworks have no framework index")
    func noIndexForSymbols() {
        #expect(source.frameworkIndexURL(forFrameworkPath: "/documentation/swiftui/view") == nil)
        #expect(source.frameworkIndexURL(forFrameworkPath: "/tutorials/swiftui") == nil)
    }

    @Test("Apple content is never downloaded in bulk")
    func noOfflineDownload() {
        #expect(!source.allowsOfflineDownload)
    }

    @Test("Page data and web URLs follow developer.apple.com's layout")
    func pageURLs() {
        #expect(source.pageDataURL(forPath: "/documentation/swift/mainactor")?.absoluteString
            == "https://developer.apple.com/tutorials/data/documentation/swift/mainactor.json")
        #expect(source.webURL(forPath: "/documentation/swift/mainactor")?.absoluteString
            == "https://developer.apple.com/documentation/swift/mainactor")
    }
}
