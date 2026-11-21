import SwiftUI

/// The anvil shown wherever something loads, in place of a spinner, in the three sizes Anvil's spinners come in. It plays the animation chosen in the settings, the strike over and over or the glow, and keeps its size however much room it is offered.
struct AnvilLoader: NSViewRepresentable {
    enum Size {
        case mini
        case small
        case regular

        var anvilWidth: CGFloat {
            switch self {
            case .mini: 12
            case .small: 16
            case .regular: 28
            }
        }
    }

    var size = Size.small

    func makeNSView(context: Context) -> AnvilLoaderView {
        AnvilLoaderView(anvilWidth: size.anvilWidth)
    }

    func updateNSView(_ view: AnvilLoaderView, context: Context) {}

    func sizeThatFits(_ proposal: ProposedViewSize, nsView view: AnvilLoaderView, context: Context) -> CGSize? {
        view.intrinsicContentSize
    }
}
