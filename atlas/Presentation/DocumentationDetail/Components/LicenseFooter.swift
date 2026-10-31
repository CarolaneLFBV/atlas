import SwiftUI

struct LicenseFooter: View {
    let permission: RenderingPermission
    let webURL: URL?

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.inline) {
            if case .fullContent(let license) = permission {
                Label {
                    VStack(alignment: .leading, spacing: Spacing.tight) {
                        Text(license.attribution)
                        if let url = license.url {
                            Link(license.name, destination: url)
                        } else {
                            Text(license.name)
                        }
                    }
                } icon: {
                    Image(systemName: AtlasSymbol.license)
                }
            }
            if let webURL {
                Link(destination: webURL) {
                    Label(.detailViewOriginalPage, systemImage: AtlasSymbol.openExternal)
                }
            }
        }
        .font(.atlasCaption)
        .foregroundStyle(AtlasColor.secondaryText)
    }
}
