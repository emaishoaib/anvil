import Foundation

/// The folders inside `~/Library` where apps keep their own files. Each raw value is the folder's path inside the Library.
public enum LibraryFolder: String, CaseIterable, Sendable {
    case applicationSupport = "Application Support"
    case caches = "Caches"
    case preferences = "Preferences"
    case preferencesByHost = "Preferences/ByHost"
    case containers = "Containers"
    case groupContainers = "Group Containers"
    case savedApplicationState = "Saved Application State"
    case httpStorages = "HTTPStorages"
    case webKit = "WebKit"
    case logs = "Logs"
    case launchAgents = "LaunchAgents"
    case applicationScripts = "Application Scripts"

    public func url(inLibrary library: URL) -> URL {
        library.appending(path: rawValue, directoryHint: .isDirectory)
    }
}
