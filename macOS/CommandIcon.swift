import LauncherKit
import SwiftUI

struct CommandIcon: View {
    let command: LauncherCommand

    var body: some View {
        switch command {
        case .defineWord: AppIcon(path: "/System/Applications/Dictionary.app")
        case .createQuickLink: SymbolIcon(symbol: "link", colour: .red)
        case .settings: SymbolIcon(symbol: "gearshape.fill", colour: .gray)
        }
    }
}

private struct SymbolIcon: View {
    private static let size: CGFloat = 22

    let symbol: String
    let colour: Color

    var body: some View {
        Image(systemName: symbol)
            .font(.system(size: 11, weight: .bold))
            .foregroundStyle(.white)
            .frame(width: Self.size, height: Self.size)
            .background(colour.gradient, in: .rect(cornerRadius: 5))
    }
}
