import SwiftUI

/// What the handle reports while a row is dragged: how far it has moved, and when it is let go.
struct RowDrag {
    let changed: (CGFloat) -> Void
    let ended: () -> Void
}

/// A chosen currency being dragged: where it started, how far it has moved and where it would land, and how far each row is shifted to make room for it.
struct CurrencyDrag {
    let source: Int
    let translation: CGFloat
    let count: Int

    func destination(rowHeight: CGFloat) -> Int {
        min(max(source + Int((translation / rowHeight).rounded()), 0), count - 1)
    }

    func offset(of index: Int, rowHeight: CGFloat) -> CGFloat {
        guard index != source else { return translation }
        let destination = destination(rowHeight: rowHeight)
        if source < destination, (source + 1...destination).contains(index) { return -rowHeight }
        if destination < source, (destination..<source).contains(index) { return rowHeight }
        return 0
    }
}

struct DragHandle: View {
    let drag: RowDrag

    var body: some View {
        Image(systemName: "line.3.horizontal")
            .foregroundStyle(.secondary)
            .frame(width: 22, height: 26)
            .contentShape(.rect)
            .help("Drag to Reorder")
            .gesture(
                DragGesture(minimumDistance: 1, coordinateSpace: .global)
                    .onChanged { drag.changed($0.translation.height) }
                    .onEnded { _ in drag.ended() }
            )
    }
}
