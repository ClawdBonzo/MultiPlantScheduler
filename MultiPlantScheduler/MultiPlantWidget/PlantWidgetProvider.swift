import WidgetKit
import SwiftData
import Foundation

// Minimal model copies for widget access (must match main app's schema)
@Model
final class WidgetPlant {
    var id: UUID = UUID()
    var name: String = ""
    var wateringIntervalDays: Int = 7
    var lastWateredDate: Date?
    var createdAt: Date = Date.now
    var wateringStreak: Int = 0
    var species: String?
    var photoData: Data?
    var room: String?
    var notes: String?
    var fertilizerType: String?
    var lastFertilizedDate: Date?
    var healthStatus: String?
    var lastHealthCheckDate: Date?
    var preferredNotificationHour: Int?
    var preferredNotificationMinute: Int?

    // Widget-only relationships stubs (must exist to match schema but are unused)
    // SwiftData will ignore missing relationship targets in read-only mode

    init() {}

    var nextWateringDate: Date {
        if let lastWatered = lastWateredDate {
            return lastWatered.addingTimeInterval(Double(wateringIntervalDays) * 86400)
        }
        return createdAt.addingTimeInterval(Double(wateringIntervalDays) * 86400)
    }

    var daysUntilWatering: Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date.now)
        let nextDate = calendar.startOfDay(for: nextWateringDate)
        return calendar.dateComponents([.day], from: today, to: nextDate).day ?? 0
    }
}

struct PlantWidgetProvider: TimelineProvider {
    private let appGroupID = "group.com.clawdbonzo.MultiPlantScheduler"

    func placeholder(in context: Context) -> PlantWidgetEntry {
        PlantWidgetEntry.placeholder
    }

    func getSnapshot(in context: Context, completion: @escaping (PlantWidgetEntry) -> Void) {
        completion(PlantWidgetEntry.placeholder)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<PlantWidgetEntry>) -> Void) {
        let isPremium = UserDefaults(suiteName: appGroupID)?.bool(forKey: "isPremium") ?? false

        guard isPremium else {
            let entry = PlantWidgetEntry(date: Date(), plants: [], isPremium: false)
            let timeline = Timeline(entries: [entry], policy: .after(Date().addingTimeInterval(3600)))
            completion(timeline)
            return
        }

        do {
            let storeURL: URL = {
                guard let url = FileManager.default.containerURL(
                    forSecurityApplicationGroupIdentifier: appGroupID
                ) else {
                    return URL.applicationSupportDirectory.appendingPathComponent("MultiPlantScheduler.store")
                }
                return url.appendingPathComponent("MultiPlantScheduler.store")
            }()

            let schema = Schema([WidgetPlant.self])
            let config = ModelConfiguration(schema: schema, url: storeURL, allowsSave: false)
            let container = try ModelContainer(for: schema, configurations: [config])
            let context = ModelContext(container)

            let descriptor = FetchDescriptor<WidgetPlant>()
            let plants = try context.fetch(descriptor)

            let widgetPlants = plants
                .sorted { $0.daysUntilWatering < $1.daysUntilWatering }
                .prefix(5)
                .map { plant in
                    WidgetPlantData(
                        id: plant.id,
                        name: plant.name,
                        daysUntilWatering: plant.daysUntilWatering,
                        emoji: "🌿"
                    )
                }

            let entry = PlantWidgetEntry(date: Date(), plants: Array(widgetPlants), isPremium: true)

            let nextRefresh = Calendar.current.startOfDay(
                for: Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()
            )
            let refreshDate = min(Date().addingTimeInterval(3600), nextRefresh)

            let timeline = Timeline(entries: [entry], policy: .after(refreshDate))
            completion(timeline)
        } catch {
            print("Widget data error: \(error)")
            let entry = PlantWidgetEntry(date: Date(), plants: [], isPremium: true)
            let timeline = Timeline(entries: [entry], policy: .after(Date().addingTimeInterval(3600)))
            completion(timeline)
        }
    }
}
