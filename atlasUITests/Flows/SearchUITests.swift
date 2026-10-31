import XCTest

final class SearchUITests: XCTestCase {
    override func setUp() {
        continueAfterFailure = false
    }

    @MainActor
    func testSearchingShowsATopHitThatOpensThePage() {
        let app = XCUIApplication.launchAtlasForTesting()
        app.buttons["library.search"].tap()

        let field = app.searchFields.firstMatch
        XCTAssertTrue(field.waitForExistence(timeout: 5))
        field.typeText("NavigationStack")

        let topHit = app.buttons["search.topHit"]
        XCTAssertTrue(topHit.waitForExistence(timeout: 5))
        topHit.tap()

        XCTAssertTrue(app.buttons["bookmarkButton"].waitForExistence(timeout: 5))
    }
}
