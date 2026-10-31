import Testing
@testable import atlas

@Suite("FrameworkIdentity")
struct FrameworkIdentityTests {
    @Test("Fallback indices are deterministic and in range")
    func stableIndex() {
        let first = FrameworkIdentity.stableIndex(for: "somenewkit", count: 10)
        #expect(first == FrameworkIdentity.stableIndex(for: "somenewkit", count: 10))
        #expect((0..<10).contains(first))
    }

    @Test("Framework names are normalized for lookup")
    func normalization() {
        #expect(FrameworkIdentity.normalizedKey("Core ML") == "coreml")
        #expect(FrameworkIdentity.normalizedKey("App Intents") == "appintents")
    }

    @Test("Known frameworks use the handoff's monograms, whatever their spelling")
    func curatedMonograms() {
        #expect(FrameworkIdentity.of("SwiftUI").monogram == "SU")
        #expect(FrameworkIdentity.of("Core ML").monogram == "ML")
        #expect(FrameworkIdentity.of("Swift Evolution").monogram == "SE")
    }

    @Test("Versioned catalogue titles keep their guide's identity")
    func versionedTitles() {
        #expect(FrameworkIdentity.of("The Swift Programming Language (6.4 beta)") == FrameworkIdentity.of("The Swift Programming Language"))
        #expect(FrameworkIdentity.of("Swift Concurrency") == FrameworkIdentity.of("Migrating to Swift 6"))
        #expect(FrameworkIdentity.of("Foundation Models").monogram != FrameworkIdentity.of("Foundation").monogram)
    }

    @Test("Other names get a monogram from their initials")
    func derivedMonograms() {
        #expect(FrameworkIdentity.monogram(for: "App Intents") == "AI")
        #expect(FrameworkIdentity.monogram(for: "MapKit") == "Ma")
        #expect(FrameworkIdentity.of(nil).monogram == "?")
    }
}
