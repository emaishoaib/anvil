import Foundation

/// The folders where apps keep their own files, each found from where the search starts. Most sit inside `~/Library`, one of them inside Application Support, and the last two are the per-user cache and temp folders under `/var/folders`. A folder whose root cannot be found has no URL.
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
    case crashReporter
    case userCache
    case userTemp

    public func url(in roots: SearchRoots) -> URL? {
        switch self {
        case .userCache: roots.userCache
        case .userTemp: roots.userTemp
        default: pathInLibrary.map { roots.library.appending(path: $0, directoryHint: .isDirectory) }
        }
    }

    var holdsFoldersNamedAfterApps: Bool {
        switch self {
        case .applicationSupport, .caches, .logs: true
        default: false
        }
    }

    private var pathInLibrary: String? {
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
        case .crashReporter: "Application Support/CrashReporter"
        case .userCache, .userTemp: nil
        }
    }
}
