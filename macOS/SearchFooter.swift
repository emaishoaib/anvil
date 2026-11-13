import LauncherKit
import SwiftUI

struct SearchFooter: View {
    static let height: CGFloat = 40

    let mode: SearchMode
    let selected: SearchResult?

    var body: some View {
        VStack(spacing: 0) {
            Divider()
            HStack(spacing: 8) {
                switch mode {
                case .launcher:
                    Image(.menuBarIcon)
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 16, height: 16)
                        .foregroundStyle(.secondary)
                case .defineWord:
                    AppIcon(path: LauncherCommand.defineWord.iconPath)
                    Text(LauncherCommand.defineWord.name)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                if let action {
                    Text(action)
                        .fontWeight(.medium)
                    Image(systemName: "return")
                        .font(.system(size: 11, weight: .semibold))
                        .padding(.horizontal, 7)
                        .padding(.vertical, 4)
                        .background(.primary.opacity(0.08), in: .rect(cornerRadius: 4))
                }
            }
            .padding(.horizontal, 12)
            .frame(height: Self.height - 1)
            .background(.primary.opacity(0.02))
        }
    }

    private var action: String? {
        switch selected {
        case .answer: "Copy Answer"
        case .app: "Open Application"
        case .command: "Open Command"
        case .word: "Open in Dictionary"
        case nil: nil
        }
    }
}
