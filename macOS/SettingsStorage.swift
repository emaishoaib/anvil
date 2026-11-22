import Foundation

/// Where Anvil keeps its settings. Without a settings folder each tool keeps them in the user defaults. With one, they all live in a single settings file in that folder, each tool or group of preferences under a section of its own, and saving a section leaves the others as they are. A file that cannot be read is never written over. A section that isn't there yet is brought in from the file it used to have in the folder, and that file is then moved to the Trash.
enum SettingsStorage {
    private static let fileName = "settings.json"
    private static let folderKey = "settings.folder"
    private static let rulesFolderKey = "rules.folder"

    static var folder: URL? {
        get {
            let path = UserDefaults.standard.string(forKey: folderKey) ?? UserDefaults.standard.string(forKey: rulesFolderKey)
            return path.map { URL(filePath: $0, directoryHint: .isDirectory) }
        }
        set {
            UserDefaults.standard.set(newValue?.path, forKey: folderKey)
            UserDefaults.standard.removeObject(forKey: rulesFolderKey)
        }
    }

    static func load<Value: Decodable>(_ type: Value.Type, section: String, oldFile: String, settingsKey: String) throws -> Value? {
        guard let folder else {
            return try UserDefaults.standard.data(forKey: settingsKey).map { try JSONDecoder().decode(type, from: $0) }
        }
        guard let saved = try self.section(section, oldFile: oldFile, in: folder) else { return nil }
        return try JSONDecoder().decode(type, from: JSONSerialization.data(withJSONObject: saved))
    }

    /// A section as plain JSON, or nil when neither it nor its old file is there. A file that cannot be read throws.
    static func section(_ section: String, oldFile: String, in folder: URL) throws -> Any? {
        if let saved = try sections(in: folder)?[section] { return saved }
        return try bringIn(section, from: folder.appending(path: oldFile), into: folder)
    }

    static func save<Value: Encodable>(_ value: Value, section: String, settingsKey: String) {
        guard let data = try? JSONEncoder().encode(value) else { return }
        guard let folder else { return UserDefaults.standard.set(data, forKey: settingsKey) }
        guard let object = try? JSONSerialization.jsonObject(with: data) else { return }
        write(object, section: section, into: folder)
    }

    static func problem(reading section: String) -> String {
        "Anvil couldn't read the \(section) section of \(fileName). Nothing here can be changed until it's fixed."
    }

    /// The file's sections by name, or nil when there is no file yet. A file that is there but isn't a set of sections throws.
    private static func sections(in folder: URL) throws -> [String: Any]? {
        let url = folder.appending(path: fileName)
        guard FileManager.default.fileExists(atPath: url.path) else { return nil }
        guard let sections = try JSONSerialization.jsonObject(with: Data(contentsOf: url)) as? [String: Any] else { throw CocoaError(.fileReadCorruptFile) }
        return sections
    }

    @discardableResult static func write(_ object: Any, section: String, into folder: URL) -> Bool {
        let current: [String: Any]?
        do { current = try sections(in: folder) } catch { return false }
        var sections = current ?? [:]
        sections[section] = object
        guard let data = try? JSONSerialization.data(withJSONObject: sections, options: [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]) else { return false }
        return (try? data.write(to: folder.appending(path: fileName), options: .atomic)) != nil
    }

    private static func bringIn(_ section: String, from oldFile: URL, into folder: URL) throws -> Any? {
        guard FileManager.default.fileExists(atPath: oldFile.path) else { return nil }
        let saved = try JSONSerialization.jsonObject(with: Data(contentsOf: oldFile))
        guard write(saved, section: section, into: folder) else { return saved }
        try? FileManager.default.trashItem(at: oldFile, resultingItemURL: nil)
        return saved
    }
}
