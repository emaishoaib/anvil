import SwiftUI

struct ToolPage: View {
    let tool: Tool
    @AppStorage private var isOn: Bool

    init(tool: Tool) {
        self.tool = tool
        _isOn = AppStorage(wrappedValue: tool.isOnByDefault, tool.isOnKey)
    }

    var body: some View {
        Form {
            Section {
                ToolHeader(tool: tool)
            }
            Section {
                Toggle("Use \(tool.name)", isOn: $isOn)
            }
            if tool == .windows {
                WindowShortcutsSection()
            } else if tool != .rules, !tool.shortcuts.isEmpty {
                Section("Shortcuts") {
                    ForEach(tool.shortcuts) { shortcut in
                        ShortcutRow(shortcut: shortcut, clashes: tool.clashes(with: shortcut))
                    }
                }
            }
            if tool == .launcher {
                QuickLinksSection()
            }
            if tool == .windows {
                SnappingSection()
            }
            if tool == .mouse {
                ScrollingSection()
                RulesSection(group: .mouseButtons)
                LogitechSection()
            }
            if tool == .rules {
                RulesSection(group: .keysAndApps)
                KeySwapsSection()
            }
        }
        .formStyle(.grouped)
        .navigationTitle(tool.name)
        .onChange(of: isOn) {
            if tool == .mouse { LogitechDevices.shared.applyMouseTool() }
            guard tool == .keepAwake, !isOn else { return }
            Task { await KeepAwake.shared.setActive(false) }
        }
    }
}

private struct ToolHeader: View {
    let tool: Tool

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: tool.symbol)
                .font(.title)
                .foregroundStyle(.tint)
                .frame(width: 40)
            VStack(alignment: .leading, spacing: 2) {
                Text(tool.name)
                    .font(.headline)
                Text(tool.summary)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

private struct ShortcutRow: View {
    let shortcut: Shortcut
    let clashes: [ShortcutClash]

    var body: some View {
        LabeledContent {
            Text(shortcut.keys)
        } label: {
            Text(shortcut.action)
            if !clashes.isEmpty {
                Label("Also used by \(clashes.map(\.name).formatted(.list(type: .and)))", systemImage: "exclamationmark.triangle.fill")
                    .foregroundStyle(.orange)
            }
        }
    }
}
