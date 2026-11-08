import XCTest

final class NavigationUITests: XCTestCase {
    override func setUp() {
        continueAfterFailure = false
    }

    @MainActor
    func testSectionsShowTheirScreens() {
        let app = XCUIApplication.launchAtlasForTesting()

        XCTAssertTrue(app.navigationBars["Library"].waitForExistence(timeout: 5), "Library isn't shown at launch")
        app.openSection("Bookmarks")
        XCTAssertTrue(app.staticTexts["No Bookmarks"].waitForExistence(timeout: 5), "Bookmarks didn't open")
        app.openSection("Snippets")
        XCTAssertTrue(app.navigationBars["Snippets"].waitForExistence(timeout: 5), "Snippets didn't open")
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
