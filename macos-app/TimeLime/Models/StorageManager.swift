import Foundation

class StorageManager {
    static let shared = StorageManager()

    private let eventsKey = "timelime_events"
    private let fileManager = FileManager.default
    private var eventsFileURL: URL {
        let appSupport = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let appDirectory = appSupport.appendingPathComponent("TimeLime", isDirectory: true)

        // Create directory if it doesn't exist
        if !fileManager.fileExists(atPath: appDirectory.path) {
            try? fileManager.createDirectory(at: appDirectory, withIntermediateDirectories: true)
        }

        return appDirectory.appendingPathComponent("events.json")
    }

    private init() {}

    // MARK: - Save Events
    func saveEvents(_ events: [Event]) {
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let data = try encoder.encode(events)
            try data.write(to: eventsFileURL)
        } catch {
            print("Error saving events: \(error.localizedDescription)")
        }
    }

    // MARK: - Load Events
    func loadEvents() -> [Event] {
        guard fileManager.fileExists(atPath: eventsFileURL.path) else {
            return []
        }

        do {
            let data = try Data(contentsOf: eventsFileURL)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let events = try decoder.decode([Event].self, from: data)
            return events
        } catch {
            print("Error loading events: \(error.localizedDescription)")
            return []
        }
    }

    // MARK: - Export/Import
    func exportEvents(_ events: [Event]) -> Data? {
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            encoder.outputFormatting = .prettyPrinted
            return try encoder.encode(events)
        } catch {
            print("Error exporting events: \(error.localizedDescription)")
            return nil
        }
    }

    func importEvents(from data: Data) -> [Event]? {
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let events = try decoder.decode([Event].self, from: data)
            return events
        } catch {
            print("Error importing events: \(error.localizedDescription)")
            return nil
        }
    }

    // MARK: - Clear Data
    func clearAllData() {
        if fileManager.fileExists(atPath: eventsFileURL.path) {
            try? fileManager.removeItem(at: eventsFileURL)
        }
    }
}
