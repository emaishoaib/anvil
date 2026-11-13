import SwiftUI

@MainActor @Observable final class WindowShortcutsModel {
    private(set) var combos = WindowShortcuts.shared.all

    func set(_ combo: KeyCombo?, for command: WindowCommand) {
        WindowShortcuts.shared.set(combo, for: command)
        combos = WindowShortcuts.shared.all
    }

    func clashes(for command: WindowCommand) -> [ShortcutClash] {
        guard let combo = combos[command] else { return [] }
        return Tool.windows.clashes(with: Shortcut(combo: combo, action: command.title))
    }
}

struct WindowShortcutsSection: View {
    @State private var model = WindowShortcutsModel()

    var body: some View {
        Section("Shortcuts") {
            ForEach(WindowCommand.allCases, id: \.self) { command in
                WindowShortcutRow(command: command, combo: model.combos[command], clashes: model.clashes(for: command)) { combo in
                    model.set(combo, for: command)
                }
            }
        }
    }
}

private struct WindowShortcutRow: View {
    let command: WindowCommand
    let combo: KeyCombo?
    let clashes: [ShortcutClash]
    let record: (KeyCombo?) -> Void

    var body: some View {
        LabeledContent {
            ShortcutRecorder(combo: combo, record: record)
        } label: {
            Text(command.title)
            if !clashes.isEmpty {
                Label("Also used by \(clashes.map(\.name).formatted(.list(type: .and)))", systemImage: "exclamationmark.triangle.fill")
                    .foregroundStyle(.orange)
            }
        }
    }
}
