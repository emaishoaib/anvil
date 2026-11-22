import Foundation

/// Keeps the General, AI and Windows sections of the settings file in step with the preferences Anvil reads those settings from, so they follow the settings folder to another Mac. A change to one of those preferences is written to its section, and whenever the folder or the file changes, the sections are read back into the preferences. A missing section is written from the preferences, a section missing some settings gets them with their current values, defaults included, and one that cannot be read is left alone and never written over until it is fixed. A change to any other preference writes nothing, so an edit to the file is not lost to unrelated changes before it is read. Without a settings folder there is nothing to keep in step.
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

    /// Reads every section into the preferences. Nothing is written back while it reads, so a section not yet read is never written over with the values it is about to replace.
    func reload() {
        guard let folder = SettingsStorage.folder else { return }
        isReloading = true
        defer { isReloading = false }
        var changedKeys: Set<String> = []
        for section in MirroredSettings.sections {
            let saved: Any?
            do { saved = try SettingsStorage.section(section.name, oldFile: section.oldFile, in: folder) } catch { continue }
            guard let saved else {
                write(section, into: folder)
                continue
            }
            guard let values = saved as? [String: Any] else { continue }
            for entry in section.entries {
                guard let value = values[entry.name], !Self.matches(UserDefaults.standard.object(forKey: entry.key), value) else { continue }
                UserDefaults.standard.set(value, forKey: entry.key)
                changedKeys.insert(entry.key)
            }
            if section.entries.contains(where: { values[$0.name] == nil }) {
                write(section, into: folder)
            } else {
                written[section.name] = Self.encoded(section)
            }
        }
        applyChanges(to: changedKeys)
    }

    private func writeChanges() {
        guard !isReloading, let folder = SettingsStorage.folder else { return }
        for section in MirroredSettings.sections where Self.encoded(section) != written[section.name] && Self.canWrite(section, in: folder) {
            write(section, into: folder)
        }
    }

    private func write(_ section: MirroredSettings.Section, into folder: URL) {
        guard SettingsStorage.write(Self.values(of: section), section: section.name, into: folder) else { return }
        written[section.name] = Self.encoded(section)
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

    private static func values(of section: MirroredSettings.Section) -> [String: Any] {
        Dictionary(uniqueKeysWithValues: section.entries.compactMap { entry in
            UserDefaults.standard.object(forKey: entry.key).map { (entry.name, $0) }
        })
    }

    private static func encoded(_ section: MirroredSettings.Section) -> Data? {
        try? JSONSerialization.data(withJSONObject: values(of: section), options: [.sortedKeys])
    }

    /// Whether a section can take the preferences: it isn't there yet, or it reads as a set of named values. One that can't be read is left for you to fix.
    private static func canWrite(_ section: MirroredSettings.Section, in folder: URL) -> Bool {
        do {
            guard let saved = try SettingsStorage.section(section.name, oldFile: section.oldFile, in: folder) else { return true }
            return saved is [String: Any]
        } catch {
            return false
        }
    }

    private static func matches(_ current: Any?, _ saved: Any) -> Bool {
        guard let current = current as? NSObject, let saved = saved as? NSObject else { return false }
        return current.isEqual(saved)
    }
}
