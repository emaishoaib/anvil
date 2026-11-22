/// What an amount is counted in: a unit such as kilometres, or a currency named by its ISO code. Two units are the same when they have the same label, because every unit in the catalogue has a label of its own.
enum Measure: Equatable {
    case unit(UnitEntry)
    case currency(String)

    static func == (lhs: Measure, rhs: Measure) -> Bool {
        switch (lhs, rhs) {
        case (.unit(let left), .unit(let right)): left.label == right.label
        case (.currency(let left), .currency(let right)): left == right
        default: false
        }
    }

    func measuresTheSameAs(_ other: Measure) -> Bool {
        switch (self, other) {
        case (.unit(let left), .unit(let right)): left.measuresTheSameAs(right)
        case (.currency, .currency): true
        default: false
        }
    }
}
