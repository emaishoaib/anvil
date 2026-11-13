public enum HIDPPReply: Equatable, Sendable {
    case answer([UInt8])
    case error(UInt8)

    static let shortReportID: UInt8 = 0x10
    static let errorFeatureIndex: UInt8 = 0xFF
    static let olderErrorFeatureIndex: UInt8 = 0x8F
    static let headerLength = 4
    static let errorLength = 6

    public init?(report: [UInt8], answering request: HIDPPRequest) {
        guard report.count >= Self.headerLength,
              report[0] == Self.shortReportID || report[0] == HIDPPRequest.longReportID,
              report[1] == request.deviceIndex
        else { return nil }
        let echoesRequest = report.count >= Self.errorLength
            && report[3] == request.featureIndex
            && report[4] == request.functionAndSoftwareID
        switch report[2] {
        case Self.errorFeatureIndex, Self.olderErrorFeatureIndex:
            guard echoesRequest else { return nil }
            self = .error(report[5])
        case request.featureIndex:
            guard report[3] == request.functionAndSoftwareID else { return nil }
            self = .answer(Array(report.dropFirst(Self.headerLength)))
        default:
            return nil
        }
    }

    public var parameters: [UInt8]? {
        guard case .answer(let parameters) = self else { return nil }
        return parameters
    }
}
