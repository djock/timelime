import SwiftUI

struct MonthlyView: View {
    @ObservedObject var viewModel: EventViewModel
    @State private var selectedMonth: Date = Date()
    @State private var selectedEvent: Event?

    private let weekDays = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]

    var body: some View {
        VStack(spacing: 16) {
            // Month selector
            monthSelector

            // Event filter
            if !viewModel.events.isEmpty {
                eventPicker
            }

            // Calendar grid
            if let selectedEvent = selectedEvent {
                calendarGrid(for: selectedEvent)
            } else {
                Text("Select an event to view check-ins")
                    .foregroundColor(.secondary)
                    .frame(maxHeight: .infinity)
            }
        }
        .padding()
        .onAppear {
            selectedEvent = viewModel.events.first
        }
    }

    private var monthSelector: some View {
        HStack {
            Button(action: { changeMonth(by: -1) }) {
                Image(systemName: "chevron.left")
            }
            .buttonStyle(.plain)

            Text(DateUtils.monthName(for: selectedMonth))
                .font(.headline)
                .frame(minWidth: 150)

            Button(action: { changeMonth(by: 1) }) {
                Image(systemName: "chevron.right")
            }
            .buttonStyle(.plain)

            Spacer()

            Button("Today") {
                selectedMonth = Date()
            }
            .buttonStyle(.bordered)
            .controlSize(.small)
        }
    }

    private var eventPicker: some View {
        Menu {
            ForEach(viewModel.sortedEvents) { event in
                Button(action: { selectedEvent = event }) {
                    HStack {
                        Circle()
                            .fill(colorForHex(event.color))
                            .frame(width: 8, height: 8)
                        Text(event.title)
                    }
                }
            }
        } label: {
            HStack {
                if let event = selectedEvent {
                    Circle()
                        .fill(colorForHex(event.color))
                        .frame(width: 8, height: 8)
                    Text(event.title)
                } else {
                    Text("Select Event")
                }
                Image(systemName: "chevron.down")
                    .font(.caption)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color(NSColor.controlBackgroundColor))
            .cornerRadius(6)
        }
        .buttonStyle(.plain)
    }

    private func calendarGrid(for event: Event) -> some View {
        VStack(spacing: 8) {
            // Week day headers
            HStack(spacing: 4) {
                ForEach(weekDays, id: \.self) { day in
                    Text(day)
                        .font(.caption2)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                }
            }

            // Calendar days
            let weeks = DateUtils.weeksInMonth(selectedMonth)
            ForEach(0..<weeks.count, id: \.self) { weekIndex in
                HStack(spacing: 4) {
                    ForEach(0..<7, id: \.self) { dayIndex in
                        if let date = weeks[weekIndex][dayIndex] {
                            dayCell(date: date, event: event)
                        } else {
                            Color.clear
                                .frame(maxWidth: .infinity)
                                .aspectRatio(1, contentMode: .fit)
                        }
                    }
                }
            }

            // Stats
            eventStats(for: event)
        }
    }

    private func dayCell(date: Date, event: Event) -> some View {
        let hasCheckIn = event.hasCheckIn(on: date)
        let isToday = DateUtils.isToday(date)
        let isInRange = date >= event.startDate && (event.endDate == nil || date <= event.endDate!)

        return VStack(spacing: 2) {
            Text("\(Calendar.current.component(.day, from: date))")
                .font(.caption)
                .fontWeight(isToday ? .bold : .regular)
                .foregroundColor(isToday ? .white : .primary)

            if isInRange {
                Circle()
                    .fill(hasCheckIn ? colorForHex(event.color) : Color.gray.opacity(0.2))
                    .frame(width: 6, height: 6)
            }
        }
        .frame(maxWidth: .infinity)
        .aspectRatio(1, contentMode: .fit)
        .background(isToday ? Color.accentColor : Color.clear)
        .cornerRadius(4)
        .onTapGesture {
            if isInRange {
                viewModel.toggleCheckIn(for: event, on: date)
                // Refresh the view
                if let index = viewModel.events.firstIndex(where: { $0.id == event.id }) {
                    selectedEvent = viewModel.events[index]
                }
            }
        }
    }

    private func eventStats(for event: Event) -> some View {
        HStack(spacing: 20) {
            statItem(title: "Total", value: "\(event.totalCheckIns)")
            statItem(title: "Current Streak", value: "\(event.currentStreak)")
            statItem(title: "Longest Streak", value: "\(event.longestStreak)")
        }
        .padding(.top, 8)
    }

    private func statItem(title: String, value: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.headline)
            Text(title)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }

    private func changeMonth(by value: Int) {
        if let newDate = Calendar.current.date(byAdding: .month, value: value, to: selectedMonth) {
            selectedMonth = newDate
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
