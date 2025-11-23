import SwiftUI

struct WeeklyView: View {
    @ObservedObject var viewModel: EventViewModel
    @State private var selectedWeek: Date = Date()

    private let weekDays = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]

    var body: some View {
        VStack(spacing: 16) {
            // Week selector
            weekSelector

            if viewModel.events.isEmpty {
                emptyStateView
            } else {
                // Week grid
                weekGrid
            }
        }
        .padding()
    }

    private var weekSelector: some View {
        HStack {
            Button(action: { changeWeek(by: -1) }) {
                Image(systemName: "chevron.left")
            }
            .buttonStyle(.plain)

            Text(weekRangeText)
                .font(.headline)
                .frame(minWidth: 200)

            Button(action: { changeWeek(by: 1) }) {
                Image(systemName: "chevron.right")
            }
            .buttonStyle(.plain)

            Spacer()

            Button("Today") {
                selectedWeek = Date()
            }
            .buttonStyle(.bordered)
            .controlSize(.small)
        }
    }

    private var weekRangeText: String {
        let startOfWeek = DateUtils.startOfWeek(for: selectedWeek)
        let endOfWeek = DateUtils.endOfWeek(for: selectedWeek)
        return "\(DateUtils.formatDate(startOfWeek, format: "MMM d")) - \(DateUtils.formatDate(endOfWeek, format: "MMM d, yyyy"))"
    }

    private var weekGrid: some View {
        VStack(spacing: 12) {
            // Day headers
            HStack(spacing: 4) {
                Text("")
                    .frame(width: 100, alignment: .leading)

                ForEach(0..<7, id: \.self) { dayIndex in
                    let date = DateUtils.daysInWeek(starting: selectedWeek)[dayIndex]
                    VStack(spacing: 2) {
                        Text(weekDays[dayIndex])
                            .font(.caption2)
                            .fontWeight(.semibold)

                        Text("\(Calendar.current.component(.day, from: date))")
                            .font(.caption)
                            .foregroundColor(DateUtils.isToday(date) ? .accentColor : .primary)
                    }
                    .frame(maxWidth: .infinity)
                }
            }

            Divider()

            // Events
            ScrollView {
                ForEach(viewModel.sortedEvents) { event in
                    eventRow(event)
                        .padding(.vertical, 4)
                }
            }
        }
    }

    private func eventRow(_ event: Event) -> some View {
        HStack(spacing: 4) {
            // Event info
            VStack(alignment: .leading, spacing: 4) {
                Text(event.title)
                    .font(.caption)
                    .lineLimit(1)

                HStack(spacing: 4) {
                    Circle()
                        .fill(colorForHex(event.color))
                        .frame(width: 6, height: 6)

                    Text(event.checkInFrequency.displayName)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            .frame(width: 100, alignment: .leading)

            // Check-in cells
            ForEach(0..<7, id: \.self) { dayIndex in
                let date = DateUtils.daysInWeek(starting: selectedWeek)[dayIndex]
                checkInCell(date: date, event: event)
            }
        }
    }

    private func checkInCell(date: Date, event: Event) -> some View {
        let hasCheckIn = event.hasCheckIn(on: date)
        let isToday = DateUtils.isToday(date)
        let isInRange = date >= event.startDate && (event.endDate == nil || date <= event.endDate!)

        return ZStack {
            RoundedRectangle(cornerRadius: 4)
                .fill(isToday ? Color.accentColor.opacity(0.1) : Color.clear)

            if isInRange {
                Circle()
                    .fill(hasCheckIn ? colorForHex(event.color) : Color.gray.opacity(0.2))
                    .frame(width: 12, height: 12)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 40)
        .contentShape(Rectangle())
        .onTapGesture {
            if isInRange {
                viewModel.toggleCheckIn(for: event, on: date)
            }
        }
        .help(isInRange ? (hasCheckIn ? "Remove check-in" : "Add check-in") : "")
    }

    private var emptyStateView: some View {
        VStack(spacing: 12) {
            Image(systemName: "calendar.badge.plus")
                .font(.system(size: 48))
                .foregroundColor(.secondary)

            Text("No events yet")
                .font(.headline)
                .foregroundColor(.secondary)

            Text("Add your first event to get started")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxHeight: .infinity)
    }

    private func changeWeek(by value: Int) {
        if let newDate = Calendar.current.date(byAdding: .weekOfYear, value: value, to: selectedWeek) {
            selectedWeek = newDate
        }
    }

    private func colorForHex(_ hex: String) -> Color {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r = Double((int >> 16) & 0xFF) / 255.0
        let g = Double((int >> 8) & 0xFF) / 255.0
        let b = Double(int & 0xFF) / 255.0
        return Color(red: r, green: g, blue: b)
    }
}
