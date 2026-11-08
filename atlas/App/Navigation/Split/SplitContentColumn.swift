import SwiftUI

struct SplitContentColumn: View {
    let selection: SidebarItem?
    @Environment(AppDependencies.self) private var dependencies

    var body: some View {
        switch selection {
        case .framework(let framework):
            FrameworkContentColumn(viewModel: DocumentationDetailViewModel(
                entry: framework.entry,
                getDetail: dependencies.getDocumentationDetail
            ))
        case .section(let section):
            AppSectionView(section: section)
        case nil:
            AppSectionView(section: .library)
        }
    }
}
