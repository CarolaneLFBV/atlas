import Testing
@testable import atlas

@Suite("DocCKindMapper")
struct DocCKindMapperTests {
    @Test("Navigator index types map to documentation kinds", arguments: [
        ("module", DocumentationKind.framework),
        ("article", .article),
        ("class", .symbol(.classType)),
        ("struct", .symbol(.structure)),
        ("protocol", .symbol(.protocol)),
        ("method", .symbol(.method)),
        ("property", .symbol(.property)),
        ("init", .symbol(.initializer)),
        ("macro", .symbol(.macro)),
        ("sampleCode", .sampleCode),
    ])
    func navigatorTypes(type: String, expected: DocumentationKind) {
        #expect(DocCKindMapper.kind(navigatorType: type) == expected)
    }

    @Test("Group markers and missing types are not pages")
    func nonPages() {
        #expect(DocCKindMapper.kind(navigatorType: "groupMarker") == .unknown)
        #expect(DocCKindMapper.kind(navigatorType: nil) == .unknown)
    }
}
