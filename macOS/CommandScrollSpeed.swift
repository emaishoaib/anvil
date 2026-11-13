nonisolated enum CommandScrollSpeed: String, CaseIterable, Identifiable {
    case tenth, quarter, half, twice, fourTimes, tenTimes

    var id: Self { self }

    var gain: Double {
        switch self {
        case .tenth: 0.1
        case .quarter: 0.25
        case .half: 0.5
        case .twice: 2
        case .fourTimes: 4
        case .tenTimes: 10
        }
    }

    var name: String {
        switch self {
        case .tenth: "A tenth"
        case .quarter: "A quarter"
        case .half: "Half"
        case .twice: "Twice"
        case .fourTimes: "Four times"
        case .tenTimes: "Ten times"
        }
    }
}
