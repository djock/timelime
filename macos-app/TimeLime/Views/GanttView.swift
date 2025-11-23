import SwiftUI

struct GanttView: View {
    @ObservedObject var viewModel: EventViewModel
    @State private var selectedYear: Date = Date()

    private let months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]

    var body: some View {
        VStack(spacing: 16) {
            // Year selector
            yearSelector

            if viewModel.events.isEmpty {
                emptyStateView
            } else {
                // Gantt chart
                ganttChart
            }
        }
        .padding()
    }

    private var yearSelector: some View {
        HStack {
            Button(action: { changeYear(by: -1) }) {
                Image(systemName: "chevron.left")
            }
            .buttonStyle(.plain)

            Text(DateUtils.formatDate(selectedYear, format: "yyyy"))
                .font(.headline)
                .frame(minWidth: 60)

            Button(action: { changeYear(by: 1) }) {
                Image(systemName: "chevron.right")
            }
            .buttonStyle(.plain)

            Spacer()

            Button("Today") {
                selectedYear = Date()
            }
            .buttonStyle(.bordered)
            .controlSize(.small)
        }
    }

    private var ganttChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Month headers
            HStack(spacing: 0) {
                Text("")
                    .frame(width: 120, alignment: .leading)

                ForEach(0..<12, id: \.self) { index in
                    Text(months[index])
                        .font(.caption2)
                        .frame(maxWidth: .infinity)
                }
            }

            Divider()

            // Events
            ForEach(viewModel.sortedEvents) { event in
                eventRow(event)
            }
        }
    }

    private func eventRow(_ event: Event) -> some View {
        HStack(spacing: 0) {
            // Event name
            VStack(alignment: .leading, spacing: 2) {
                Text(event.title)
                    .font(.caption)
                    .lineLimit(1)

                HStack(spacing: 4) {
                    Circle()
                        .fill(colorForHex(event.color))
                        .frame(width: 6, height: 6)

                    Text("\(event.totalCheckIns) check-ins")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            .frame(width: 120, alignment: .leading)

            // Timeline
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Grid lines
                    HStack(spacing: 0) {
                        ForEach(0..<12, id: \.self) { _ in
                            Rectangle()
                                .fill(Color.gray.opacity(0.1))
                                .frame(maxWidth: .infinity)
                                .border(Color.gray.opacity(0.2), width: 0.5)
                        }
                    }

                    // Event timeline
                    timelineBar(for: event, width: geometry.size.width)
                }
            }
            .frame(height: 40)
        }
    }

    private func timelineBar(for event: Event, width: CGFloat) -> some View {
        let yearStart = DateUtils.startOfYear(for: selectedYear)
        let yearEnd = DateUtils.endOfYear(for: selectedYear)
        let totalDays = DateUtils.daysBetween(yearStart, yearEnd)

        let eventStart = max(event.startDate, yearStart)
        let eventEnd = min(event.endDate ?? yearEnd, yearEnd)

        let startOffset = CGFloat(DateUtils.daysBetween(yearStart, eventStart)) / CGFloat(totalDays) * width
        let duration = CGFloat(DateUtils.daysBetween(eventStart, eventEnd)) / CGFloat(totalDays) * width

        return RoundedRectangle(cornerRadius: 4)
            .fill(colorForHex(event.color))
            .frame(width: max(duration, 4), height: 20)
            .offset(x: startOffset)
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

    private func changeYear(by value: Int) {
        if let newDate = Calendar.current.date(byAdding: .year, value: value, to: selectedYear) {
            selectedYear = newDate
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
