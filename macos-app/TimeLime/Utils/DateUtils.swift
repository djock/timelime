import Foundation

struct DateUtils {
    static let calendar = Calendar.current

    // MARK: - Date Formatting
    static func formatDate(_ date: Date, format: String = "MMM d, yyyy") -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: date)
    }

    static func formatShortDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter.string(from: date)
    }

    // MARK: - Week Calculations
    static func weekNumber(for date: Date) -> Int {
        return calendar.component(.weekOfYear, from: date)
    }

    static func startOfWeek(for date: Date) -> Date {
        let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
        return calendar.date(from: components) ?? date
    }

    static func endOfWeek(for date: Date) -> Date {
        let startOfWeek = startOfWeek(for: date)
        return calendar.date(byAdding: .day, value: 6, to: startOfWeek) ?? date
    }

    static func daysInWeek(starting date: Date) -> [Date] {
        var days: [Date] = []
        let startOfWeek = startOfWeek(for: date)

        for i in 0..<7 {
            if let day = calendar.date(byAdding: .day, value: i, to: startOfWeek) {
                days.append(day)
            }
        }

        return days
    }

    // MARK: - Month Calculations
    static func startOfMonth(for date: Date) -> Date {
        let components = calendar.dateComponents([.year, .month], from: date)
        return calendar.date(from: components) ?? date
    }

    static func endOfMonth(for date: Date) -> Date {
        let startOfMonth = startOfMonth(for: date)
        return calendar.date(byAdding: DateComponents(month: 1, day: -1), to: startOfMonth) ?? date
    }

    static func daysInMonth(for date: Date) -> Int {
        return calendar.range(of: .day, in: .month, for: date)?.count ?? 30
    }

    static func monthName(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: date)
    }

    static func daysInMonth(_ date: Date) -> [Date] {
        var days: [Date] = []
        let startOfMonth = startOfMonth(for: date)
        let daysCount = daysInMonth(for: date)

        for i in 0..<daysCount {
            if let day = calendar.date(byAdding: .day, value: i, to: startOfMonth) {
                days.append(day)
            }
        }

        return days
    }

    static func weeksInMonth(_ date: Date) -> [[Date?]] {
        var weeks: [[Date?]] = []
        let startOfMonth = startOfMonth(for: date)
        let firstWeekday = calendar.component(.weekday, from: startOfMonth)
        let daysCount = daysInMonth(for: date)

        var currentWeek: [Date?] = Array(repeating: nil, count: firstWeekday - 1)
        var currentDay = 0

        while currentDay < daysCount {
            if let day = calendar.date(byAdding: .day, value: currentDay, to: startOfMonth) {
                currentWeek.append(day)
                currentDay += 1

                if currentWeek.count == 7 {
                    weeks.append(currentWeek)
                    currentWeek = []
                }
            } else {
                currentDay += 1
            }
        }

        if !currentWeek.isEmpty {
            while currentWeek.count < 7 {
                currentWeek.append(nil)
            }
            weeks.append(currentWeek)
        }

        return weeks
    }

    // MARK: - Year Calculations
    static func startOfYear(for date: Date) -> Date {
        let components = calendar.dateComponents([.year], from: date)
        return calendar.date(from: components) ?? date
    }

    static func endOfYear(for date: Date) -> Date {
        let startOfYear = startOfYear(for: date)
        return calendar.date(byAdding: DateComponents(year: 1, day: -1), to: startOfYear) ?? date
    }

    static func monthsInYear(for date: Date) -> [Date] {
        var months: [Date] = []
        let startOfYear = startOfYear(for: date)

        for i in 0..<12 {
            if let month = calendar.date(byAdding: .month, value: i, to: startOfYear) {
                months.append(month)
            }
        }

        return months
    }

    // MARK: - Date Comparison
    static func isSameDay(_ date1: Date, _ date2: Date) -> Bool {
        return calendar.isDate(date1, inSameDayAs: date2)
    }

    static func isToday(_ date: Date) -> Bool {
        return calendar.isDateInToday(date)
    }

    static func daysBetween(_ start: Date, _ end: Date) -> Int {
        let components = calendar.dateComponents([.day], from: start, to: end)
        return abs(components.day ?? 0)
    }

    // MARK: - Check-in Period Calculation
    static func checkInPeriods(for event: Event, in range: DateInterval) -> [Date] {
        var periods: [Date] = []
        var currentDate = max(range.start, event.startDate)
        let endDate = event.endDate.map { min(range.end, $0) } ?? range.end

        let interval: DateComponents
        switch event.checkInFrequency {
        case .daily:
            interval = DateComponents(day: 1)
        case .weekly:
            interval = DateComponents(day: 7)
        case .monthly:
            interval = DateComponents(month: 1)
        case .yearly:
            interval = DateComponents(year: 1)
        case .custom:
            interval = DateComponents(day: event.customDays ?? 1)
        }

        while currentDate <= endDate {
            periods.append(currentDate)
            if let nextDate = calendar.date(byAdding: interval, to: currentDate) {
                currentDate = nextDate
            } else {
                break
            }
        }

        return periods
    }
}
