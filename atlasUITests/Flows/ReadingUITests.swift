import XCTest

final class ReadingUITests: XCTestCase {
    override func setUp() {
        continueAfterFailure = false
    }

    @MainActor
    private func openFixturePage(in app: XCUIApplication) {
        app.buttons["library.search"].tap()
        let field = app.searchFields.firstMatch
        XCTAssertTrue(field.waitForExistence(timeout: 5))
        field.typeText("NavigationStack")
        let topHit = app.buttons["search.topHit"]
        XCTAssertTrue(topHit.waitForExistence(timeout: 5))
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

        app.openTab("Bookmarks")
        XCTAssertTrue(app.staticTexts["NavigationStack"].waitForExistence(timeout: 5))
    }

    @MainActor
    func testCopyingCodeConfirmsIt() {
        let app = XCUIApplication.launchAtlasForTesting()
        openFixturePage(in: app)

        let copy = app.buttons["codeSnippet.copy"].firstMatch
        XCTAssertTrue(copy.waitForExistence(timeout: 5))
        copy.tap()

        XCTAssertTrue(app.buttons["Copied"].waitForExistence(timeout: 2))
    }
}
