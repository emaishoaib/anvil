import ShellKit
import SwiftUI

/// The alias editor inside the search bar: the name typed in the shell, and the command it runs.
struct AliasForm: View {
    private static let fieldWidth: CGFloat = 460
    private static let hint = "The name can use letters, digits, dashes, underscores and dots. New shells pick the alias up."

    @Binding var draft: Alias
    @Binding var field: AliasField
    @FocusState private var focus: AliasField?

    var body: some View {
        Grid(alignment: .leading, horizontalSpacing: 20, verticalSpacing: 22) {
            GridRow {
                FormLabel(text: "Name")
                TextField("Name", text: $draft.name, prompt: Text(verbatim: "czsh"))
                    .focused($focus, equals: .name)
            }
            GridRow(alignment: .firstTextBaseline) {
                FormLabel(text: "Command")
                VStack(alignment: .leading, spacing: 10) {
                    TextField("Command", text: $draft.command, prompt: Text(verbatim: "code ~/.zshrc"))
                        .focused($focus, equals: .command)
                    Text(Self.hint)
                        .font(.callout)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .textFieldStyle(.roundedBorder)
        .controlSize(.large)
        .frame(width: Self.fieldWidth + 120)
        .padding(.vertical, 28)
        .frame(maxWidth: .infinity)
        .onAppear { DispatchQueue.main.async { focus = field } }
        .onChange(of: field) { focus = field }
        .onChange(of: focus) { if let focus { field = focus } }
    }
}
