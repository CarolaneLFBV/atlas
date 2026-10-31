import SwiftUI

/// Search with its field attached to the enclosing column, used by the iPad and Mac split view.
struct SearchScreen: View {
    @State private var viewModel: SearchViewModel

    init(viewModel: SearchViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        SearchView(viewModel: viewModel)
            .documentationSearchField(text: $viewModel.query, scope: $viewModel.scope)
    }
}
