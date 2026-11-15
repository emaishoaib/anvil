import Foundation

/// The folders where apps keep their own files, each found from where the search starts. All of them sit inside `~/Library` for now.
public enum SearchFolder: CaseIterable, Sendable {
    case applicationSupport
    case caches
    case preferences
    case preferencesByHost
    case containers
    case groupContainers
    case savedApplicationState
    case httpStorages
    case webKit
    case logs
    case launchAgents
    case applicationScripts

    public func url(in roots: SearchRoots) -> URL {
        roots.library.appending(path: pathInLibrary, directoryHint: .isDirectory)
    }

    var holdsFoldersNamedAfterApps: Bool {
        switch self {
        case .applicationSupport, .caches, .logs: true
        default: false
        }
    }

    private var pathInLibrary: String {
        switch self {
        case .applicationSupport: "Application Support"
        case .caches: "Caches"
        case .preferences: "Preferences"
        case .preferencesByHost: "Preferences/ByHost"
        case .containers: "Containers"
        case .groupContainers: "Group Containers"
        case .savedApplicationState: "Saved Application State"
        case .httpStorages: "HTTPStorages"
        case .webKit: "WebKit"
        case .logs: "Logs"
        case .launchAgents: "LaunchAgents"
        case .applicationScripts: "Application Scripts"
        }
    }
}
