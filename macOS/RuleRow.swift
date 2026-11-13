import RulesKit
import SwiftUI

struct RuleRow: View {
    let rule: Rule
    let edit: () -> Void
    let delete: () -> Void

    var body: some View {
        HStack(spacing: 10) {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    RuleTriggerLabel(trigger: rule.trigger)
                    Image(systemName: "arrow.right")
                        .foregroundStyle(.secondary)
                    RuleActionLabel(action: rule.action)
                }
                Text(rule.apps.summary)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                if !clashes.isEmpty {
                    Label("Also used by \(clashes.map(\.name).formatted(.list(type: .and)))", systemImage: "exclamationmark.triangle.fill")
                        .font(.caption)
                        .foregroundStyle(.orange)
                }
            }
            Spacer()
            Button("Edit", systemImage: "pencil", action: edit)
            Button("Delete", systemImage: "trash", action: delete)
        }
        .buttonStyle(.borderless)
        .labelStyle(.iconOnly)
        .contentShape(.rect)
        .onTapGesture(count: 2, perform: edit)
    }

    private var clashes: [ShortcutClash] {
        guard case .shortcut(let keystroke) = rule.trigger else { return [] }
        return Tool.rules.clashes(with: Shortcut(combo: KeyCombo(keystroke), action: ""))
    }
}

private struct RuleTriggerLabel: View {
    let trigger: RuleTrigger

    var body: some View {
        switch trigger {
        case .shortcut(let keystroke): KeyCaps(combo: KeyCombo(keystroke))
        case .mouseButton(let number): Text(MouseButton.name(for: number))
        case .appOpens: Text("App opens")
        case .appComesToFront: Text("App comes to front")
        }
    }
}

private struct RuleActionLabel: View {
    let action: RuleAction

    var body: some View {
        switch action {
        case .sendShortcut(let keystroke):
            HStack(spacing: 6) {
                Text("Send")
                KeyCaps(combo: KeyCombo(keystroke))
            }
        case .chooseMenuItem(let path):
            Text("Choose \(path.joined(separator: " > "))")
        case .playSound(let name):
            Text("Play \(name)")
        case .quitApp:
            Text("Quit it")
        case .resizeWindow(let width, let height):
            Text("Resize its window to \(width) by \(height)")
        case .swipe(let direction):
            Text(direction == .back ? "Swipe back" : "Swipe forward")
        }
    }
}
