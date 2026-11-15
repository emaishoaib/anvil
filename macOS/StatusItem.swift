import SwiftUI

/// One item in the footer's status row: a symbol and a short title. How much it stands out follows its emphasis, from quiet grey to an orange warning.
struct StatusItem: View {
    enum Emphasis {
        case quiet
        case active
        case warning
    }

    let symbol: String
    let title: String
    let emphasis: Emphasis

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: symbol)
                .foregroundStyle(symbolStyle)
            Text(title)
                .foregroundStyle(titleStyle)
        }
        .font(.callout)
    }

    private var symbolStyle: AnyShapeStyle {
        switch emphasis {
        case .quiet: AnyShapeStyle(.secondary)
        case .active: AnyShapeStyle(.primary)
        case .warning: AnyShapeStyle(.orange)
        }
    }

    private var titleStyle: AnyShapeStyle {
        emphasis == .warning ? AnyShapeStyle(.orange) : AnyShapeStyle(.secondary)
    }
}
