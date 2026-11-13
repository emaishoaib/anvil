import Carbon.HIToolbox
import SwiftUI

struct KeyCap<Label: View>: View {
    @ViewBuilder let label: Label

    var body: some View {
        label
            .font(.system(size: 11, weight: .semibold))
            .frame(minWidth: 10)
            .padding(.horizontal, 7)
            .padding(.vertical, 4)
            .background(.primary.opacity(0.08), in: .rect(cornerRadius: 4))
    }
}

struct KeyCaps: View {
    let combo: KeyCombo

    var body: some View {
        HStack(spacing: 4) {
            ForEach(combo.modifiers.orderedSymbols, id: \.self) { symbol in
                KeyCap { Text(symbol) }
            }
            KeyCap {
                if combo.keyCode == kVK_Return {
                    Image(systemName: "return")
                } else {
                    Text(combo.keyName)
                }
            }
        }
    }
}
