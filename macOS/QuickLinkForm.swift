import LauncherKit
import SwiftUI

struct QuickLinkForm: View {
    private static let fieldWidth: CGFloat = 460

    @Binding var draft: QuickLink
    @FocusState private var isNameFocused: Bool

    var body: some View {
        Grid(alignment: .leading, horizontalSpacing: 20, verticalSpacing: 22) {
            GridRow {
                FormLabel(text: "Name")
                TextField("Name", text: $draft.name, prompt: Text("Quick link name"))
                    .focused($isNameFocused)
            }
            GridRow(alignment: .firstTextBaseline) {
                FormLabel(text: "Link")
                VStack(alignment: .leading, spacing: 10) {
                    LinkField(link: $draft.link) { SearchBar.shared.presentModal(FilePicker.chooseFileOrFolder) }
                    Text(QuickLink.placeholderHint)
                        .font(.callout)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            GridRow {
                FormLabel(text: "Open With")
                OpenWithPicker(link: draft, selection: $draft.openWith)
                    .labelsHidden()
            }
        }
        .textFieldStyle(.roundedBorder)
        .controlSize(.large)
        .frame(width: Self.fieldWidth + 120)
        .padding(.vertical, 28)
        .frame(maxWidth: .infinity)
        .onAppear(perform: focusName)
    }

    /// Puts the cursor in the name field with all its text selected, ready to be typed over. It waits until the form is in the window, because a field can't take focus before then, and selects the text once the field has focus.
    private func focusName() {
        DispatchQueue.main.async {
            isNameFocused = true
            DispatchQueue.main.async { NSApp.sendAction(#selector(NSText.selectAll(_:)), to: nil, from: nil) }
        }
    }
}

private struct FormLabel: View {
    let text: String

    var body: some View {
        Text(text)
            .foregroundStyle(.secondary)
            .gridColumnAlignment(.trailing)
    }
}
