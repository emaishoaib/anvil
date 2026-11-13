import Foundation

public enum DatePhrases {
    public static func answer(for query: String, now: Date = .now, calendar: Calendar = .current, locale: Locale = .current) -> Answer? {
        guard let phrase = DatePhrase(query), let date = phrase.date(from: now, in: calendar) else { return nil }
        let timeZone = Date.FormatStyle(locale: locale, calendar: calendar, timeZone: calendar.timeZone).timeZone(.localizedGMT(.short))
        let time = Date.FormatStyle(date: .omitted, time: .shortened, locale: locale, calendar: calendar, timeZone: calendar.timeZone)
        let output = phrase.showsTime
            ? Date.FormatStyle(date: .long, time: .shortened, locale: locale, calendar: calendar, timeZone: calendar.timeZone)
            : Date.FormatStyle(date: .complete, time: .omitted, locale: locale, calendar: calendar, timeZone: calendar.timeZone)
        return Answer(
            input: query.trimmingCharacters(in: .whitespaces),
            inputLabel: "\(now.formatted(time)), \(now.formatted(timeZone))",
            output: date.formatted(output),
            outputLabel: phrase.showsTime ? date.formatted(timeZone) : relativeDays(from: now, to: date, calendar: calendar, locale: locale),
            copyText: date.formatted(output)
        )
    }

    private static func relativeDays(from now: Date, to date: Date, calendar: Calendar, locale: Locale) -> String {
        let days = calendar.dateComponents([.day], from: calendar.startOfDay(for: now), to: calendar.startOfDay(for: date)).day ?? 0
        let formatter = RelativeDateTimeFormatter()
        formatter.dateTimeStyle = .named
        formatter.unitsStyle = .full
        formatter.locale = locale
        formatter.calendar = calendar
        return formatter.localizedString(from: DateComponents(day: days)).capitalisingFirstLetter
    }
}
