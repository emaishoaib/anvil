import Foundation

struct UnitEntry: @unchecked Sendable {
    let names: [String]
    let unit: Dimension
    let one: String
    let other: String
    let label: String
    let defaultTarget: String

    init(_ names: [String], _ unit: Dimension, _ symbol: String, _ label: String, to defaultTarget: String) {
        self.init(names, unit, one: symbol, other: symbol, label, to: defaultTarget)
    }

    init(_ names: [String], _ unit: Dimension, one: String, other: String, _ label: String, to defaultTarget: String) {
        self.names = names
        self.unit = unit
        self.one = one
        self.other = other
        self.label = label
        self.defaultTarget = defaultTarget
    }

    func display(_ value: Double) -> String {
        value == 1 ? one : other
    }

    func measuresTheSameAs(_ other: UnitEntry) -> Bool {
        type(of: unit).baseUnit().symbol == type(of: other.unit).baseUnit().symbol
    }

    func convert(_ amount: Double, to target: UnitEntry) -> Double {
        target.unit.converter.value(fromBaseUnitValue: unit.converter.baseUnitValue(fromValue: amount))
    }
}
