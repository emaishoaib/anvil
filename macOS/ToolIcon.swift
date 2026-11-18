import SwiftUI

/// The icon a tool shows on the settings page, in one colour: an SF Symbol, or for the Switcher, the window grid from Hop's app icon, since no symbol shows switching between windows.
nonisolated enum ToolIcon {
    case symbol(String)
    case hop
}

/// A tool's icon at a given size, taking the colour of the text around it.
struct ToolIconView: View {
    let icon: ToolIcon
    let size: CGFloat

    var body: some View {
        switch icon {
        case .symbol(let name):
            Image(systemName: name)
                .font(.system(size: size))
                .frame(width: size, height: size)
        case .hop:
            HopIcon()
                .frame(width: size, height: size)
        }
    }
}
