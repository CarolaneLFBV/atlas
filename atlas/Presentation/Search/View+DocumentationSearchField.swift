import SwiftUI

extension View {
    /// The documentation search field, with automatic placement: in the separated Search tab on iPhone,
    /// in the column's toolbar on iPad and Mac. Autocorrection is off because queries are API names.
    func documentationSearchField(text: Binding<String>, scope: Binding<SearchScope>) -> some View {
        self
            .searchable(text: text, prompt: Text(.librarySearchPrompt))
            .searchScopes(scope, activation: .onSearchPresentation) {
                ForEach(SearchScope.allCases, id: \.self) { Text($0.title).tag($0) }
            }
            .autocorrectionDisabled()
            #if os(iOS)
            .textInputAutocapitalization(.never)
            #endif
    }
}
