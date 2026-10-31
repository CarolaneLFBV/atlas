import XCTest

extension XCUIApplication {
    /// Mirrors `LaunchArguments.uiTesting` in the app target.
    @MainActor
    static func launchAtlasForTesting() -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments.append("-atlas-ui-testing")
        app.launch()
        return app
    }

    @MainActor
    func openTab(_ title: String) {
        tabBars.buttons[title].firstMatch.tap()
    }
}
