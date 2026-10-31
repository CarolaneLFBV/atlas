import SwiftUI

struct DocumentationDestinationView: View {
    let entry: DocumentationEntry
    @Environment(AppDependencies.self) private var dependencies

    var body: some View {
        DocumentationDetailView(
            viewModel: DocumentationDetailViewModel(entry: entry, getDetail: dependencies.getDocumentationDetail)
        )
        .id(entry.id)
    }
}

extension View {
    func documentationDestinations() -> some View {
        navigationDestination(for: DocumentationEntry.self) { entry in
            DocumentationDestinationView(entry: entry)
        }
    }
}
