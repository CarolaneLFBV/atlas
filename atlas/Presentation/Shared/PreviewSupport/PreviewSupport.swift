import SwiftUI

// Preview-only code: excluded from Release builds.
#if DEBUG
/// Dependencies and environment for SwiftUI previews ONLY: an in-memory store and fixture documentation.
enum PreviewSupport {
    static let dependencies = AppDependencies.inMemory(documentationRepository: PreviewDocumentationRepository())
}

extension View {
    func previewEnvironment(_ dependencies: AppDependencies = PreviewSupport.dependencies) -> some View {
        appDependencies(dependencies)
    }
}
#endif
