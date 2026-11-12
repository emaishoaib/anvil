import SwiftUI

struct ToolPage: View {
    let tool: Tool
    @AppStorage private var isOn: Bool

    init(tool: Tool) {
        self.tool = tool
        _isOn = AppStorage(wrappedValue: false, tool.isOnKey)
    }

    var body: some View {
        Form {
            Section {
                ToolHeader(tool: tool)
            }
            Section {
                Toggle("Use \(tool.name)", isOn: $isOn)
            }
        }
        .formStyle(.grouped)
        .navigationTitle(tool.name)
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
