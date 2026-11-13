import Foundation

enum DatePhrase: Equatable {
    case now
    case offset(DateComponents)
    case day(Int)
    case weekday(Int, WeekdayChoice)

    private static let weekdays = ["sunday", "monday", "tuesday", "wednesday", "thursday", "friday", "saturday"]
    private static let shortestWeekday = 3
    private static let suffixes: [(words: [String], sign: Int)] = [
        (["from", "now"], 1), (["from", "today"], 1), (["after", "now"], 1), (["later"], 1),
        (["ago"], -1), (["before", "now"], -1), (["earlier"], -1),
    ]

    var showsTime: Bool {
        switch self {
        case .now, .offset: true
        case .day, .weekday: false
        }
    }

    init?(_ query: String) {
        let words = Self.words(in: query)
        switch words {
        case ["now"]: self = .now
        case ["today"]: self = .day(0)
        case ["tomorrow"]: self = .day(1)
        case ["yesterday"]: self = .day(-1)
        default:
            guard let phrase = Self.weekday(from: words) ?? Self.offset(from: words) else { return nil }
            self = phrase
        }
    }

    func date(from now: Date, in calendar: Calendar) -> Date? {
        switch self {
        case .now: now
        case .offset(let components): calendar.date(byAdding: components, to: now)
        case .day(let days): calendar.date(byAdding: .day, value: days, to: now)
        case .weekday(let weekday, let choice):
            calendar.date(byAdding: .day, value: choice.days(to: weekday, from: calendar.component(.weekday, from: now)), to: now)
        }
    }

    private static func words(in query: String) -> [String] {
        query.lowercased()
            .replacingOccurrences(of: ",", with: " ")
            .replacingOccurrences(of: #"(\d)([a-z])"#, with: "$1 $2", options: .regularExpression)
            .split(separator: " ")
            .map(String.init)
            .filter { $0 != "and" }
    }

    private static func weekday(from words: [String]) -> DatePhrase? {
        switch words.count {
        case 1:
            guard let index = weekdays.firstIndex(of: words[0]) else { return nil }
            return .weekday(index + 1, .this)
        case 2:
            guard let choice = WeekdayChoice(rawValue: words[0]), words[1].count >= shortestWeekday,
                  let index = weekdays.firstIndex(where: { $0.hasPrefix(words[1]) })
            else { return nil }
            return .weekday(index + 1, choice)
        default:
            return nil
        }
    }

    private static func offset(from words: [String]) -> DatePhrase? {
        var amounts = words
        let sign: Int
        if amounts.first == "in" {
            amounts.removeFirst()
            sign = 1
        } else if let suffix = suffixes.first(where: { Array(amounts.suffix($0.words.count)) == $0.words }) {
            amounts.removeLast(suffix.words.count)
            sign = suffix.sign
        } else {
            return nil
        }
        guard !amounts.isEmpty, amounts.count.isMultiple(of: 2) else { return nil }
        var components = DateComponents()
        for start in stride(from: 0, to: amounts.count, by: 2) {
            guard let amount = amount(from: amounts[start]), let unit = TimeUnit(word: amounts[start + 1]) else { return nil }
            unit.add(amount * sign, to: &components)
        }
        return .offset(components)
    }

    private static func amount(from word: String) -> Int? {
        switch word {
        case "a", "an", "one": 1
        default: Int(word)
        }
    }
}

enum WeekdayChoice: String {
    case this, next, last

    func days(to weekday: Int, from today: Int) -> Int {
        let ahead = (weekday - today + 7) % 7
        switch self {
        case .this: return ahead
        case .next: return ahead == 0 ? 7 : ahead
        case .last: return ahead == 0 ? -7 : ahead - 7
        }
    }
}
