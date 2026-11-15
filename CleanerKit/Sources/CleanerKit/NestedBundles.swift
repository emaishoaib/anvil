import Foundation

/// The bundles an app carries inside itself, such as helper apps, extensions and background services. They can sit anywhere inside the app, even deep inside a framework, so the whole app is looked through.
enum NestedBundles {
    private static let bundleExtensions: Set<String> = ["app", "appex", "xpc"]

    static func urls(inAppAt appURL: URL) -> [URL] {
        let contents = appURL.appending(path: "Contents", directoryHint: .isDirectory)
        return FileManager.default.enumerator(at: contents, includingPropertiesForKeys: nil)?
            .compactMap { $0 as? URL }
            .filter { bundleExtensions.contains($0.pathExtension.lowercased()) } ?? []
    }

    /// The names of the apps among the bundles whose name starts with one of the given names, such as `Docker Desktop` for `Docker`. Helper apps, such as `Code Helper (GPU)`, count as well.
    static func appNames(in bundles: [URL], startingWithAnyOf names: [String]) -> [String] {
        bundles
            .filter { $0.pathExtension.lowercased() == "app" }
            .map { $0.deletingPathExtension().lastPathComponent }
            .filter { appName in names.contains { appName.lowercased().hasPrefix($0.lowercased()) } }
    }
}
