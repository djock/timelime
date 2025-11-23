import Foundation
import SwiftUI

class EventViewModel: ObservableObject {
    @Published var events: [Event] = []
    @Published var selectedEvent: Event?
    @Published var currentView: ViewType = .gantt

    private let storageManager = StorageManager.shared

    enum ViewType: String, CaseIterable {
        case gantt = "Gantt"
        case monthly = "Monthly"
        case weekly = "Weekly"
    }

    init() {
        loadEvents()
    }

    // MARK: - Event Management
    func addEvent(_ event: Event) {
        events.append(event)
        saveEvents()
    }

    func updateEvent(_ event: Event) {
        if let index = events.firstIndex(where: { $0.id == event.id }) {
            events[index] = event
            saveEvents()
        }
    }

    func deleteEvent(_ event: Event) {
        events.removeAll { $0.id == event.id }
        if selectedEvent?.id == event.id {
            selectedEvent = nil
        }
        saveEvents()
    }

    func deleteEvent(at offsets: IndexSet) {
        events.remove(atOffsets: offsets)
        saveEvents()
    }

    // MARK: - Check-in Management
    func toggleCheckIn(for event: Event, on date: Date) {
        guard let index = events.firstIndex(where: { $0.id == event.id }) else { return }

        var updatedEvent = events[index]
        if updatedEvent.hasCheckIn(on: date) {
            updatedEvent.removeCheckIn(on: date)
        } else {
            updatedEvent.addCheckIn(on: date)
        }

        events[index] = updatedEvent
        saveEvents()
    }

    // MARK: - Storage
    private func saveEvents() {
        storageManager.saveEvents(events)
    }

    private func loadEvents() {
        events = storageManager.loadEvents()
    }

    // MARK: - Export/Import
    func exportData() -> Data? {
        return storageManager.exportEvents(events)
    }

    func importData(from data: Data) {
        if let importedEvents = storageManager.importEvents(from: data) {
            // Merge with existing events, avoiding duplicates
            let existingIDs = Set(events.map { $0.id })
            let newEvents = importedEvents.filter { !existingIDs.contains($0.id) }
            events.append(contentsOf: newEvents)
            saveEvents()
        }
    }

    func clearAllData() {
        events.removeAll()
        selectedEvent = nil
        storageManager.clearAllData()
    }

    // MARK: - Filtering & Sorting
    var sortedEvents: [Event] {
        events.sorted { $0.createdAt < $1.createdAt }
    }

    func events(for date: Date) -> [Event] {
        events.filter { event in
            let isAfterStart = date >= Calendar.current.startOfDay(for: event.startDate)
            let isBeforeEnd = event.endDate == nil || date <= Calendar.current.startOfDay(for: event.endDate!)
            return isAfterStart && isBeforeEnd
        }
    }
}
