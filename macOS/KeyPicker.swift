import SwiftUI

/// A menu of every key on the built-in keyboard, for choosing one side of a key swap.
struct KeyPicker: View {
    let title: String
    @Binding var selection: Int?

    var body: some View {
        Picker(title, selection: $selection) {
            Text("Choose a Key").tag(Int?.none)
            ForEach(HIDKeys.all, id: \.usage) { key in
                Text(key.name).tag(Int?.some(key.usage))
            }
        }
    }
}
