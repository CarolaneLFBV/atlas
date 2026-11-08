import XCTest

final class ReadingUITests: XCTestCase {
    override func setUp() {
        continueAfterFailure = false
    }

    @MainActor
    private func openFixturePage(in app: XCUIApplication) {
        app.buttons["library.search"].tap()
        let field = app.searchFields.firstMatch
        XCTAssertTrue(field.waitForExistence(timeout: 5), "Search field didn't appear")
        field.typeText("NavigationStack")
        let topHit = app.buttons["search.topHit"]
        XCTAssertTrue(topHit.waitForExistence(timeout: 5), "No top hit for NavigationStack")
        topHit.tap()
    }

    @MainActor
    func testBookmarkingAPageListsItInBookmarks() {
        let app = XCUIApplication.launchAtlasForTesting()
        openFixturePage(in: app)

        let bookmark = app.buttons["bookmarkButton"]
        XCTAssertTrue(bookmark.waitForExistence(timeout: 5))
        bookmark.tap()
        XCTAssertEqual(bookmark.label, "Remove Bookmark")

        app.openSection("Bookmarks")
        XCTAssertTrue(app.staticTexts["NavigationStack"].waitForExistence(timeout: 5))
    }

    @MainActor
    func testCopyingCodeConfirmsIt() {
        let app = XCUIApplication.launchAtlasForTesting()
        openFixturePage(in: app)

        let copy = app.buttons["codeSnippet.copy"].firstMatch
        XCTAssertTrue(copy.waitForExistence(timeout: 5), "No copy button on the page")
        copy.tap()

        XCTAssertTrue(app.buttons["Copied"].waitForExistence(timeout: 2), "Copy wasn't confirmed")
    }
}
