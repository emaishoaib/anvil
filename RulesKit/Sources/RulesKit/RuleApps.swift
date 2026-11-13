public enum RuleApps: Hashable, Codable, Sendable {
    case all
    case only(bundleIDs: Set<String>)

    public func apply(to bundleID: String?) -> Bool {
        switch self {
        case .all: true
        case .only(let bundleIDs): bundleID.map(bundleIDs.contains) ?? false
        }
    }

    public var isChosen: Bool { self != .all }
}
