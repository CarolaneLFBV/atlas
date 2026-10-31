import Foundation

@Observable
final class AppLaunch {
    enum State {
        case ready(AppDependencies)
        case failed(String)
    }

    let state: State

    init() {
        #if DEBUG
        if ProcessInfo.processInfo.arguments.contains(LaunchArguments.uiTesting) {
            state = .ready(.inMemory(documentationRepository: PreviewDocumentationRepository()))
            return
        }
        #endif
        do {
            state = .ready(try AppDependencies.live())
        } catch {
            state = .failed(error.localizedDescription)
        }
    }
}
