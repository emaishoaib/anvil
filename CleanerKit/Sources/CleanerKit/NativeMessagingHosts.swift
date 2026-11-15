import Foundation

/// The files browsers read to learn which program a browser extension may talk to. Each browser keeps them in a `NativeMessagingHosts` folder inside its own folder in Application Support, one or two levels down, such as `Mozilla/NativeMessagingHosts` or `Google/Chrome/NativeMessagingHosts`.
///
/// Each file gives the program's location as its `path`, so a file belongs to an app when that program sits inside the app or inside one of the app's leftover folders. A file that already sits inside one of those folders is left out, because it goes with the folder. A file that cannot be read is left alone. Files come back in order of their location.
enum NativeMessagingHosts {
    private static let folderName = "NativeMessagingHosts"
    private static let programKey = "path"

    static func files(in roots: SearchRoots, pointingInto owners: [URL]) -> [Leftover] {
        guard let applicationSupport = SearchFolder.applicationSupport.url(in: roots) else { return [] }
        let ownerComponents = owners.map(\.standardizedFileURL.pathComponents)
        let isInsideOwner = { (url: URL) in
            let components = url.standardizedFileURL.pathComponents
            return ownerComponents.contains { components.count > $0.count && components.starts(with: $0) }
        }
        return hostFolders(in: applicationSupport)
            .flatMap(contents(of:))
            .filter { file in
                guard let program = program(namedIn: file) else { return false }
                return isInsideOwner(program) && !isInsideOwner(file)
            }
            .sorted { $0.path(percentEncoded: false) < $1.path(percentEncoded: false) }
            .map { Leftover(url: $0, folder: .applicationSupport) }
    }

    private static func hostFolders(in applicationSupport: URL) -> [URL] {
        let browserFolders = contents(of: applicationSupport)
        return (browserFolders + browserFolders.flatMap(contents(of:)))
            .map { $0.appending(path: folderName, directoryHint: .isDirectory) }
            .filter { FileManager.default.fileExists(atPath: $0.path(percentEncoded: false)) }
    }

    private static func program(namedIn file: URL) -> URL? {
        guard file.pathExtension.lowercased() == "json",
              let data = try? Data(contentsOf: file),
              let manifest = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let path = manifest[programKey] as? String
        else { return nil }
        return URL(filePath: path)
    }

    private static func contents(of folder: URL) -> [URL] {
        let names = (try? FileManager.default.contentsOfDirectory(atPath: folder.path(percentEncoded: false))) ?? []
        return names.map { folder.appending(path: $0) }
    }
}
