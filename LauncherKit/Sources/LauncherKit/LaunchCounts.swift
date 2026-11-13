public struct LaunchCounts: Equatable, Sendable {
    public private(set) var byPath: [String: Int]

    public init(_ byPath: [String: Int] = [:]) {
        self.byPath = byPath
    }

    public func count(for app: InstalledApp) -> Int {
        byPath[app.url.path] ?? 0
    }

    public mutating func record(_ app: InstalledApp) {
        byPath[app.url.path, default: 0] += 1
    }
}
