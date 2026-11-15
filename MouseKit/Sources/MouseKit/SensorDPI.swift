/// A mouse sensor's DPI as its Adjustable DPI feature reports it: the DPI it uses now, and every DPI it accepts. The feature lists accepted DPIs as plain values, or as two values with a step marker between them, which stands for every step from the first value to the second.
public struct SensorDPI: Equatable, Sendable {
    static let stepMarker: UInt16 = 0b111
    static let stepMarkerShift: UInt16 = 13
    static let stepMask: UInt16 = 0x1FFF
    static let listEnd: UInt16 = 0

    public let current: Int
    public let choices: [Int]

    public init(current: Int, choices: [Int]) {
        self.current = current
        self.choices = choices
    }

    public init?(current currentParameters: [UInt8], list listParameters: [UInt8]) {
        guard currentParameters.count >= 3 else { return nil }
        let current = Int(UInt16(currentParameters[1]) << 8 | UInt16(currentParameters[2]))
        let choices = Self.choices(from: listParameters)
        guard current != 0, !choices.isEmpty else { return nil }
        self.init(current: current, choices: choices)
    }

    public var lowest: Int { choices.first ?? current }
    public var highest: Int { choices.last ?? current }

    public func nearestIndex(to dpi: Int) -> Int {
        choices.indices.min { abs(choices[$0] - dpi) < abs(choices[$1] - dpi) } ?? 0
    }

    public func nearestChoice(to dpi: Int) -> Int {
        choices.isEmpty ? current : choices[nearestIndex(to: dpi)]
    }

    private static func choices(from parameters: [UInt8]) -> [Int] {
        let values = stride(from: 1, to: parameters.count - 1, by: 2).map {
            UInt16(parameters[$0]) << 8 | UInt16(parameters[$0 + 1])
        }
        var choices: [Int] = []
        var step: Int?
        for value in values {
            guard value != listEnd else { break }
            if value >> stepMarkerShift == stepMarker {
                step = Int(value & stepMask)
                continue
            }
            if let step, step > 0, let last = choices.last {
                choices += stride(from: last + step, through: Int(value), by: step)
            } else {
                choices.append(Int(value))
            }
            step = nil
        }
        return choices
    }
}
