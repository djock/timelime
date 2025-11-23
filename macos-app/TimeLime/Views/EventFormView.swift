import SwiftUI

struct EventFormView: View {
    @ObservedObject var viewModel: EventViewModel
    let event: Event?
    @Binding var isPresented: Bool

    @State private var title: String = ""
    @State private var color: Color = .green
    @State private var checkInFrequency: CheckInFrequency = .daily
    @State private var customDays: String = "1"
    @State private var startDate: Date = Date()
    @State private var hasEndDate: Bool = false
    @State private var endDate: Date = Date()

    // Color options matching the web app theme
    private let colorOptions: [(String, Color)] = [
        ("#00ff00", .green),
        ("#ff6b9d", .pink),
        ("#4ecdc4", .cyan),
        ("#ffd93d", .yellow),
        ("#a78bfa", .purple),
        ("#fb923c", .orange),
        ("#60a5fa", .blue),
        ("#f87171", .red)
    ]

    var body: some View {
        VStack(spacing: 20) {
            Text(event == nil ? "New Event" : "Edit Event")
                .font(.title2)
                .fontWeight(.bold)

            Form {
                Section {
                    TextField("Event Title", text: $title)
                        .textFieldStyle(.roundedBorder)
                }

                Section("Color") {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 8), spacing: 8) {
                        ForEach(colorOptions, id: \.0) { colorHex, colorValue in
                            Circle()
                                .fill(colorValue)
                                .frame(width: 32, height: 32)
                                .overlay(
                                    Circle()
                                        .stroke(Color.primary, lineWidth: color == colorValue ? 3 : 0)
                                )
                                .onTapGesture {
                                    color = colorValue
                                }
                        }
                    }
                }

                Section("Check-in Frequency") {
                    Picker("Frequency", selection: $checkInFrequency) {
                        ForEach(CheckInFrequency.allCases, id: \.self) { frequency in
                            Text(frequency.displayName).tag(frequency)
                        }
                    }
                    .pickerStyle(.menu)

                    if checkInFrequency == .custom {
                        TextField("Days", text: $customDays)
                            .textFieldStyle(.roundedBorder)
                    }
                }

                Section("Date Range") {
                    DatePicker("Start Date", selection: $startDate, displayedComponents: .date)

                    Toggle("End Date", isOn: $hasEndDate)

                    if hasEndDate {
                        DatePicker("End Date", selection: $endDate, displayedComponents: .date)
                    }
                }
            }
            .formStyle(.grouped)

            HStack {
                Button("Cancel") {
                    isPresented = false
                }
                .buttonStyle(.bordered)

                Spacer()

                if event != nil {
                    Button("Delete", role: .destructive) {
                        if let event = event {
                            viewModel.deleteEvent(event)
                        }
                        isPresented = false
                    }
                    .buttonStyle(.bordered)
                }

                Button(event == nil ? "Add" : "Save") {
                    saveEvent()
                }
                .buttonStyle(.borderedProminent)
                .disabled(title.isEmpty)
            }
        }
        .padding()
        .frame(width: 400, height: 500)
        .onAppear {
            loadEventData()
        }
    }

    private func loadEventData() {
        guard let event = event else { return }

        title = event.title
        color = colorForHex(event.color)
        checkInFrequency = event.checkInFrequency
        customDays = "\(event.customDays ?? 1)"
        startDate = event.startDate
        hasEndDate = event.endDate != nil
        endDate = event.endDate ?? Date()
    }

    private func saveEvent() {
        let colorHex = hexForColor(color)
        let customDaysInt = Int(customDays) ?? 1

        if let existingEvent = event {
            var updatedEvent = existingEvent
            updatedEvent.title = title
            updatedEvent.color = colorHex
            updatedEvent.checkInFrequency = checkInFrequency
            updatedEvent.customDays = checkInFrequency == .custom ? customDaysInt : nil
            updatedEvent.startDate = startDate
            updatedEvent.endDate = hasEndDate ? endDate : nil
            updatedEvent.updatedAt = Date()

            viewModel.updateEvent(updatedEvent)
        } else {
            let newEvent = Event(
                title: title,
                color: colorHex,
                checkInFrequency: checkInFrequency,
                customDays: checkInFrequency == .custom ? customDaysInt : nil,
                startDate: startDate,
                endDate: hasEndDate ? endDate : nil
            )

            viewModel.addEvent(newEvent)
        }

        isPresented = false
    }

    private func colorForHex(_ hex: String) -> Color {
        return colorOptions.first { $0.0 == hex }?.1 ?? .green
    }

    private func hexForColor(_ color: Color) -> String {
        return colorOptions.first { $0.1 == color }?.0 ?? "#00ff00"
    }
}
