import SwiftUI

struct DeprecatedBadge: View {
    var body: some View {
        StatusBadge(text: .badgeDeprecated, style: .deprecated)
    }
}

#if DEBUG
#Preview {
    DeprecatedBadge().padding()
}
#endif
