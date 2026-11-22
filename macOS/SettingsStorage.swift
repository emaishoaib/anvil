import Foundation

/// Where the tools keep their settings. Without a settings folder each tool keeps them in the user defaults. With one, they all live in a single settings file in that folder, each tool under a section of its own, and saving a section leaves the others as they are. A file that cannot be read is never written over. A tool whose section isn't there yet brings in the file it used to have in the folder, then moves that file to the Trash.
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
        if let saved = try sections(in: folder)?[section] {
            return try JSONDecoder().decode(type, from: JSONSerialization.data(withJSONObject: saved))
        }
        return try bringIn(type, section: section, from: folder.appending(path: oldFile), into: folder)
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

    @discardableResult private static func write(_ object: Any, section: String, into folder: URL) -> Bool {
        let current: [String: Any]?
        do { current = try sections(in: folder) } catch { return false }
        var sections = current ?? [:]
        sections[section] = object
        guard let data = try? JSONSerialization.data(withJSONObject: sections, options: [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]) else { return false }
        return (try? data.write(to: folder.appending(path: fileName), options: .atomic)) != nil
    }

    private static func bringIn<Value: Decodable>(_ type: Value.Type, section: String, from oldFile: URL, into folder: URL) throws -> Value? {
        guard FileManager.default.fileExists(atPath: oldFile.path) else { return nil }
        let data = try Data(contentsOf: oldFile)
        let value = try JSONDecoder().decode(type, from: data)
        guard write(try JSONSerialization.jsonObject(with: data), section: section, into: folder) else { return value }
        try? FileManager.default.trashItem(at: oldFile, resultingItemURL: nil)
        return value
    }
}
