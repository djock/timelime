import Foundation

struct Event: Identifiable, Codable, Hashable {
    var id: UUID
    var title: String
    var color: String
    var checkInFrequency: CheckInFrequency
    var customDays: Int?
    var startDate: Date
    var endDate: Date?
    var checkIns: [CheckIn]
    var createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        title: String,
        color: String,
        checkInFrequency: CheckInFrequency = .daily,
        customDays: Int? = nil,
        startDate: Date = Date(),
        endDate: Date? = nil,
        checkIns: [CheckIn] = [],
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.color = color
        self.checkInFrequency = checkInFrequency
        self.customDays = customDays
        self.startDate = startDate
        self.endDate = endDate
        self.checkIns = checkIns
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

enum CheckInFrequency: String, Codable, CaseIterable {
    case daily = "Daily"
    case weekly = "Weekly"
    case monthly = "Monthly"
    case yearly = "Yearly"
    case custom = "Custom"

    var displayName: String {
        return self.rawValue
    }
}

struct CheckIn: Identifiable, Codable, Hashable {
    var id: UUID
    var date: Date
    var timestamp: Date

    init(id: UUID = UUID(), date: Date = Date(), timestamp: Date = Date()) {
        self.id = id
        self.date = date
        self.timestamp = timestamp
    }
}

// Extension for event statistics
extension Event {
    var totalCheckIns: Int {
        return checkIns.count
    }

    var currentStreak: Int {
        guard !checkIns.isEmpty else { return 0 }

        let sortedCheckIns = checkIns.sorted { $0.date > $1.date }
        var streak = 0
        var currentDate = Calendar.current.startOfDay(for: Date())

        for checkIn in sortedCheckIns {
            let checkInDate = Calendar.current.startOfDay(for: checkIn.date)
            let daysDifference = Calendar.current.dateComponents([.day], from: checkInDate, to: currentDate).day ?? 0

            if daysDifference == 0 || daysDifference == 1 {
                streak += 1
                currentDate = checkInDate
            } else {
                break
            }
        }

        return streak
    }

    var longestStreak: Int {
        guard !checkIns.isEmpty else { return 0 }

        let sortedCheckIns = checkIns.sorted { $0.date < $1.date }
        var maxStreak = 1
        var currentStreak = 1

        for i in 1..<sortedCheckIns.count {
            let prevDate = Calendar.current.startOfDay(for: sortedCheckIns[i - 1].date)
            let currentDate = Calendar.current.startOfDay(for: sortedCheckIns[i].date)
            let daysDifference = Calendar.current.dateComponents([.day], from: prevDate, to: currentDate).day ?? 0

            if daysDifference == 1 {
                currentStreak += 1
                maxStreak = max(maxStreak, currentStreak)
            } else if daysDifference > 1 {
                currentStreak = 1
            }
        }

        return maxStreak
    }

    func hasCheckIn(on date: Date) -> Bool {
        let calendar = Calendar.current
        return checkIns.contains { checkIn in
            calendar.isDate(checkIn.date, inSameDayAs: date)
        }
    }

    mutating func addCheckIn(on date: Date = Date()) {
        let calendar = Calendar.current
        let checkInDate = calendar.startOfDay(for: date)

        // Check if check-in already exists for this date
        if !hasCheckIn(on: checkInDate) {
            let newCheckIn = CheckIn(date: checkInDate, timestamp: Date())
            checkIns.append(newCheckIn)
            updatedAt = Date()
        }
    }

    mutating func removeCheckIn(on date: Date) {
        let calendar = Calendar.current
        checkIns.removeAll { checkIn in
            calendar.isDate(checkIn.date, inSameDayAs: date)
        }
        updatedAt = Date()
    }
}
