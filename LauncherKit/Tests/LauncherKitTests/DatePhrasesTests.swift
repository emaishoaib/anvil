import Foundation
import Testing
@testable import LauncherKit

struct DatePhrasesTests {
    let locale = Locale(identifier: "en_US")
    let now = ISO8601DateFormatter().date(from: "2026-11-13T05:48:00Z")!

    var cairo: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Africa/Cairo")!
        return calendar
    }

    func answer(_ query: String) -> Answer? {
        DatePhrases.answer(for: query, now: now, calendar: cairo, locale: locale)
    }

    func output(_ query: String) -> String? {
        answer(query)?.output.replacingOccurrences(of: "\u{202F}", with: " ")
    }

    @Test func daysFromNowKeepTheTimeOfDay() {
        #expect(output("30 days from now") == "December 13, 2026 at 7:48 AM")
    }

    @Test func inAndAnAmountLooksAhead() {
        #expect(output("in 2 hours") == "November 13, 2026 at 9:48 AM")
    }

    @Test func anHourMeansOneHour() {
        #expect(output("an hour from now") == "November 13, 2026 at 8:48 AM")
    }

    @Test func agoLooksBackAcrossSeveralUnits() {
        #expect(output("1 week and 2 days ago") == "November 4, 2026 at 7:48 AM")
    }

    @Test func monthsMoveTheCalendarMonth() {
        #expect(output("3 months later") == "February 13, 2027 at 7:48 AM")
    }

    @Test func numbersCanTouchTheirUnits() {
        #expect(output("30days from now") == "December 13, 2026 at 7:48 AM")
    }

    @Test func nowIsTheCurrentTime() {
        #expect(output("now") == "November 13, 2026 at 7:48 AM")
    }

    @Test func timedAnswersShowTheTimeAndZone() {
        let answer = answer("30 days from now")
        #expect(answer?.input == "30 days from now")
        #expect(answer?.inputLabel.replacingOccurrences(of: "\u{202F}", with: " ") == "7:48 AM, GMT+2")
        #expect(answer?.outputLabel == "GMT+2")
    }

    @Test func dayWordsShowTheDateWithItsWeekday() {
        #expect(output("tomorrow") == "Saturday, November 14, 2026")
        #expect(answer("tomorrow")?.outputLabel == "Tomorrow")
        #expect(output("yesterday") == "Thursday, November 12, 2026")
    }

    @Test func aWeekdayIsTheComingOne() {
        #expect(output("monday") == "Monday, November 16, 2026")
        #expect(answer("monday")?.outputLabel == "In 3 days")
    }

    @Test func thisWeekdayOnThatDayIsToday() {
        #expect(output("this friday") == "Friday, November 13, 2026")
        #expect(answer("friday")?.outputLabel == "Today")
    }

    @Test func nextAndLastSkipToday() {
        #expect(output("next friday") == "Friday, November 20, 2026")
        #expect(output("last friday") == "Friday, November 6, 2026")
        #expect(output("last monday") == "Monday, November 9, 2026")
    }

    @Test func shortWeekdaysWorkAfterNextOrLast() {
        #expect(output("next fri") == "Friday, November 20, 2026")
    }

    @Test func otherTextIsNotADatePhrase() {
        #expect(answer("30 days") == nil)
        #expect(answer("mon") == nil)
        #expect(answer("safari") == nil)
        #expect(answer("in") == nil)
        #expect(answer("from now") == nil)
        #expect(answer("2 bananas ago") == nil)
    }
}
