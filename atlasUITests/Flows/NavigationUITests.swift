import XCTest

final class NavigationUITests: XCTestCase {
    override func setUp() {
        continueAfterFailure = false
    }

    @MainActor
    func testTabsShowTheirScreens() {
        let app = XCUIApplication.launchAtlasForTesting()

        XCTAssertTrue(app.navigationBars["Library"].waitForExistence(timeout: 5))
        app.openTab("Bookmarks")
        XCTAssertTrue(app.staticTexts["No Bookmarks"].waitForExistence(timeout: 5))
        app.openTab("Snippets")
        XCTAssertTrue(app.navigationBars["Snippets"].waitForExistence(timeout: 5))
    }

    @MainActor
    func testLibrarySearchFieldOpensSearch() {
        let app = XCUIApplication.launchAtlasForTesting()

        let field = app.buttons["library.search"]
        XCTAssertTrue(field.waitForExistence(timeout: 5))
        field.tap()

        XCTAssertTrue(app.searchFields.firstMatch.waitForExistence(timeout: 5))
    }
}
