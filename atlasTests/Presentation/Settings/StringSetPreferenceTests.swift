import Testing
@testable import atlas

@Suite("StringSetPreference")
struct StringSetPreferenceTests {
    @Test("Values are added and removed without duplicates")
    func editing() {
        var raw = ""
        raw = StringSetPreference.setting("swift-evolution", included: true, in: raw)
        raw = StringSetPreference.setting("Developer Tools", included: true, in: raw)
        raw = StringSetPreference.setting("swift-evolution", included: true, in: raw)
        #expect(StringSetPreference.decode(raw) == ["swift-evolution", "Developer Tools"])

        raw = StringSetPreference.setting("swift-evolution", included: false, in: raw)
        #expect(StringSetPreference.decode(raw) == ["Developer Tools"])
    }
}
