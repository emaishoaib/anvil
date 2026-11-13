/// Where a device keeps its SmartShift feature, and which of the two versions it has, since they number their functions differently.
public struct SmartShiftFeature: Equatable, Sendable {
    public enum Version: CaseIterable, Sendable {
        case enhanced
        case original

        public var id: UInt16 {
            switch self {
            case .enhanced: 0x2111
            case .original: 0x2110
            }
        }

        var readFunction: UInt8 {
            switch self {
            case .enhanced: 1
            case .original: 0
            }
        }

        var writeFunction: UInt8 {
            switch self {
            case .enhanced: 2
            case .original: 1
            }
        }
    }

    public let index: UInt8
    public let version: Version

    public init(index: UInt8, version: Version) {
        self.index = index
        self.version = version
    }
}
