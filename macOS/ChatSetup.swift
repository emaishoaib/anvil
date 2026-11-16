import AppKit
import ClaudeKit
import Observation

/// The folder a new chat starts in and how freely Claude Code may act there. Both are remembered, so each new chat starts with the ones picked last. Until something is picked, a chat starts in the home folder in Manual mode, and a remembered folder that no longer exists falls back to the home folder too.
@Observable final class ChatSetup {
    private static let folderKey = "ai.folder"
    private static let modeKey = "ai.permissionMode"
    private static let home = FileManager.default.homeDirectoryForCurrentUser

    private(set) var folder = ChatSetup.rememberedFolder
    private(set) var mode = UserDefaults.standard.string(forKey: ChatSetup.modeKey).flatMap(PermissionMode.init) ?? .manual

    var displayPath: String {
        (folder.path as NSString).abbreviatingWithTildeInPath
    }

    func chooseFolder() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.canCreateDirectories = true
        panel.directoryURL = folder
        panel.message = "Choose the folder Claude Code works in"
        guard panel.runModal() == .OK, let chosen = panel.url else { return }
        folder = chosen
        UserDefaults.standard.set(chosen, forKey: Self.folderKey)
    }

    func use(_ mode: PermissionMode) {
        self.mode = mode
        UserDefaults.standard.set(mode.rawValue, forKey: Self.modeKey)
    }

    func useNextMode() {
        use(mode.next)
    }

    private static var rememberedFolder: URL {
        guard let url = UserDefaults.standard.url(forKey: folderKey), FileManager.default.fileExists(atPath: url.path) else { return home }
        return url
    }
}
