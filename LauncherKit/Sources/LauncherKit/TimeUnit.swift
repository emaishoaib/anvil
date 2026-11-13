import Foundation

enum TimeUnit {
    case second, minute, hour, day, week, month, year

    init?(word: String) {
        switch word {
        case "s", "sec", "secs", "second", "seconds": self = .second
        case "m", "min", "mins", "minute", "minutes": self = .minute
        case "h", "hr", "hrs", "hour", "hours": self = .hour
        case "d", "day", "days": self = .day
        case "w", "wk", "wks", "week", "weeks": self = .week
        case "mo", "mos", "month", "months": self = .month
        case "y", "yr", "yrs", "year", "years": self = .year
        default: return nil
        }
    }

    func add(_ amount: Int, to components: inout DateComponents) {
        switch self {
        case .second: components.second = (components.second ?? 0) + amount
        case .minute: components.minute = (components.minute ?? 0) + amount
        case .hour: components.hour = (components.hour ?? 0) + amount
        case .day: components.day = (components.day ?? 0) + amount
        case .week: components.day = (components.day ?? 0) + amount * 7
        case .month: components.month = (components.month ?? 0) + amount
        case .year: components.year = (components.year ?? 0) + amount
        }
    }
}
