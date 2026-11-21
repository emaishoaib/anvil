import Foundation

/// Keeps the settings files in the settings folder in step with the preferences Anvil reads its General, AI and Windows settings from, so those settings follow the folder to another Mac. A change to one of those preferences is written to its file, and whenever the folder or a file in it changes, the files are read back into the preferences. A missing file is written from the preferences, and a file that cannot be read is left alone and never written over until it is fixed. A change to any other preference writes nothing, so an edit to a file is not lost to unrelated changes before it is read. Without a settings folder there is nothing to keep in step.
final class SettingsMirror {
    static let shared = SettingsMirror()

    private var written: [String: Data] = [:]
    private var isReloading = false
    private var observer: NSObjectProtocol?

    func start() {
        reload()
        observer = NotificationCenter.default.addObserver(forName: UserDefaults.didChangeNotification, object: UserDefaults.standard, queue: .main) { _ in
            MainActor.assumeIsolated { SettingsMirror.shared.writeChanges() }
        }
    }

    /// Reads every file into the preferences. Nothing is written back while it reads, so a file not yet read is never written over with the values it is about to replace.
    func reload() {
        guard let folder = SettingsStorage.folder else { return }
        isReloading = true
        defer { isReloading = false }
        var changedKeys: Set<String> = []
        for file in MirroredSettings.files {
            let url = folder.appending(path: file.name)
            guard FileManager.default.fileExists(atPath: url.path) else {
                write(file, to: url)
                continue
            }
            guard let saved = Self.values(in: url) else { continue }
            for entry in file.entries {
                guard let value = saved[entry.name], !Self.matches(UserDefaults.standard.object(forKey: entry.key), value) else { continue }
                UserDefaults.standard.set(value, forKey: entry.key)
                changedKeys.insert(entry.key)
            }
            written[file.name] = Self.encoded(file)
        }
        applyChanges(to: changedKeys)
    }

    private func writeChanges() {
        guard !isReloading, let folder = SettingsStorage.folder else { return }
        for file in MirroredSettings.files {
            let url = folder.appending(path: file.name)
            guard Self.encoded(file) != written[file.name] else { continue }
            guard !FileManager.default.fileExists(atPath: url.path) || Self.values(in: url) != nil else { continue }
            write(file, to: url)
        }
    }

    private func write(_ file: MirroredSettings.File, to url: URL) {
        guard let data = Self.encoded(file) else { return }
        try? data.write(to: url, options: .atomic)
        written[file.name] = data
    }

    /// Brings the parts of Anvil that hold on to a setting in line with values just read from a file.
    private func applyChanges(to keys: Set<String>) {
        guard !keys.isEmpty else { return }
        LauncherKeys.shared.reload()
        AIKeys.shared.reload()
        WindowShortcuts.shared.reload()
        for tool in Tool.allCases where keys.contains(tool.isOnKey) { tool.setOn(tool.isOn) }
        SearchBar.shared.refreshSettings()
    }

    private static func encoded(_ file: MirroredSettings.File) -> Data? {
        let values = Dictionary(uniqueKeysWithValues: file.entries.compactMap { entry in
            UserDefaults.standard.object(forKey: entry.key).map { (entry.name, $0) }
        })
        return try? JSONSerialization.data(withJSONObject: values, options: [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes])
    }

    private static func values(in url: URL) -> [String: Any]? {
        guard let data = try? Data(contentsOf: url) else { return nil }
        return (try? JSONSerialization.jsonObject(with: data)) as? [String: Any]
    }

    private static func matches(_ current: Any?, _ saved: Any) -> Bool {
        guard let current = current as? NSObject, let saved = saved as? NSObject else { return false }
        return current.isEqual(saved)
    }
}
