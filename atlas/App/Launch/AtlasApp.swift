import SwiftUI

@main
struct AtlasApp: App {
    @State private var launch = AppLaunch()

    var body: some Scene {
        WindowGroup {
            switch launch.state {
            case .ready(let dependencies):
                RootView()
                    .appDependencies(dependencies)
            case .failed(let message):
                ErrorStateView(title: .launchErrorTitle, message: message)
            }
        }
    }
}
