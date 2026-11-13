public struct LaunchCounts: Equatable, Sendable {
    public private(set) var byKey: [String: Int]

    public init(_ byKey: [String: Int] = [:]) {
        self.byKey = byKey
    }

    public func count(for key: String) -> Int {
        byKey[key] ?? 0
    }

    public mutating func record(_ key: String) {
        byKey[key, default: 0] += 1
    }
}
