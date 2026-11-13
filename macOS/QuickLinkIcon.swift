import LauncherKit
import SwiftUI

struct QuickLinkIcon: View {
    private static let size: CGFloat = 22
    private static let faviconSize: CGFloat = 18

    let link: QuickLink

    var body: some View {
        if let site = link.site, let favicon = Favicons.shared.icon(for: site) {
            Image(nsImage: favicon)
                .resizable()
                .interpolation(.high)
                .frame(width: Self.faviconSize, height: Self.faviconSize)
                .clipShape(.rect(cornerRadius: 4))
                .frame(width: Self.size, height: Self.size)
        } else {
            AppIcon(path: link.app?.path ?? "")
        }
    }
}
