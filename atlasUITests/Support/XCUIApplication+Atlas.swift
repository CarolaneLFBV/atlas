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
    func openSection(_ title: String) {
        let tab = tabBars.buttons[title].firstMatch
        if tab.exists {
            tab.tap()
        } else {
            descendants(matching: .any)["sidebar.\(title.lowercased())"].firstMatch.tap()
        }
    }
}
