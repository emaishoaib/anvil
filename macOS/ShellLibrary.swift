import Foundation
import Observation
import ShellKit

/// The shell setup, kept in `shell.json` in Anvil's settings folder. Each time it loads or changes, it rewrites the zsh file that `~/.zshrc` sources, so the next shell that starts picks it up.
@Observable final class ShellLibrary {
    static let shared = ShellLibrary()

    static let zshFile = URL.applicationSupportDirectory.appending(path: "com.mashoaib.anvil/shell.zsh")
    private static let file = "shell.json"
    private static let settingsKey = "shell.setup"

    private(set) var setup = ShellSetup()
    private(set) var loadProblem: String?

    func start() {
        reload()
    }

    func save(_ alias: Alias) {
        setup.save(alias)
        persist()
    }

    func delete(_ alias: Alias) {
        setup.delete(alias)
        persist()
    }

    func setStartupLines(_ lines: String) {
        setup.startupLines = lines
        persist()
    }

    func setPrompt(_ prompt: String) {
        setup.prompt = prompt
        persist()
    }

    func reload() {
        do {
            loadProblem = nil
            guard let saved = try SettingsStorage.load(ShellSetup.self, file: Self.file, settingsKey: Self.settingsKey) else { return persist() }
            setup = saved
            writeZsh()
        } catch {
            loadProblem = SettingsStorage.problem(reading: Self.file)
        }
    }

    private func persist() {
        guard loadProblem == nil else { return }
        SettingsStorage.save(setup, file: Self.file, settingsKey: Self.settingsKey)
        writeZsh()
    }

    private func writeZsh() {
        try? FileManager.default.createDirectory(at: Self.zshFile.deletingLastPathComponent(), withIntermediateDirectories: true)
        try? Data(setup.zsh.utf8).write(to: Self.zshFile, options: .atomic)
    }
}
