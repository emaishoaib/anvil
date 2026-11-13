import Foundation

enum SettingsStorage {
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

    static func load<Value: Decodable>(_ type: Value.Type, file: String, settingsKey: String) throws -> Value? {
        guard let folder else {
            return try UserDefaults.standard.data(forKey: settingsKey).map { try JSONDecoder().decode(type, from: $0) }
        }
        let url = folder.appending(path: file)
        guard FileManager.default.fileExists(atPath: url.path) else { return nil }
        return try JSONDecoder().decode(type, from: Data(contentsOf: url))
    }

    static func save<Value: Encodable>(_ value: Value, file: String, settingsKey: String) {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
        guard let data = try? encoder.encode(value) else { return }
        if let folder {
            try? data.write(to: folder.appending(path: file), options: .atomic)
        } else {
            UserDefaults.standard.set(data, forKey: settingsKey)
        }
    }

    static func problem(reading file: String) -> String {
        "Anvil couldn't read \(file). Nothing here can be changed until the file is fixed."
    }
}
