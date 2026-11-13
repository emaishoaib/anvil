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

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .all:
            _ = container.nestedContainer(keyedBy: AllCodingKeys.self, forKey: .all)
        case .only(let bundleIDs):
            var only = container.nestedContainer(keyedBy: OnlyCodingKeys.self, forKey: .only)
            try only.encode(bundleIDs.sorted(), forKey: .bundleIDs)
        }
    }
}
