import SwiftData
import Foundation

/// Handles first launch setup and seed data initialization
enum FirstLaunchService {
    private static let firstLaunchKey = "com.multiplantwateringschedule.firstLaunchComplete"

    /// Check if this is the first launch of the app
    static var isFirstLaunch: Bool {
        !UserDefaults.standard.bool(forKey: firstLaunchKey)
    }

    /// Create and insert seed sample plants with varied watering states
    /// This ensures the dashboard looks interesting on first launch
    /// - Parameter context: The ModelContext to insert plants into
    static func seedSamplePlants(context: ModelContext) {
        let now = Date.now
        let sevenDaysAgo = now.addingTimeInterval(-7 * 86400)   // exactly due today
        let twelveDaysAgo = now.addingTimeInterval(-12 * 86400) // overdue (10d interval)
        let fiveDaysAgo = now.addingTimeInterval(-5 * 86400)    // fine (14d interval)
        let tenDaysAgo = now.addingTimeInterval(-10 * 86400)    // overdue (7d interval)

        // Monstera - due today (7 days since last watering, 7-day interval)
        let monstera = Plant(
            name: "Monstera",
            species: "Monstera Deliciosa",
            wateringIntervalDays: 7,
            room: "Living Room",
            notes: "Fast grower near the window"
        )
        monstera.lastWateredDate = sevenDaysAgo
        context.insert(monstera)

        // Snake Plant - fine for a while
        let snakePlant = Plant(
            name: "Snake Plant",
            species: "Sansevieria trifasciata",
            wateringIntervalDays: 14,
            room: "Bedroom",
            notes: "Very drought tolerant, hard to kill"
        )
        snakePlant.lastWateredDate = fiveDaysAgo
        context.insert(snakePlant)

        // Pothos - overdue by 2 days (12 days since watering, 10-day interval)
        let pothos = Plant(
            name: "Pothos",
            species: "Epipremnum aureum",
            wateringIntervalDays: 10,
            room: "Office",
            notes: "Trailing vine, easy care"
        )
        pothos.lastWateredDate = twelveDaysAgo
        context.insert(pothos)

        // Fiddle Leaf Fig - moderately overdue
        let fiddleLeafFig = Plant(
            name: "Fiddle Leaf Fig",
            species: "Ficus lyrata",
            wateringIntervalDays: 7,
            room: "Living Room",
            notes: "Prefers bright light, can be finicky"
        )
        fiddleLeafFig.lastWateredDate = tenDaysAgo
        context.insert(fiddleLeafFig)

        // ZZ Plant - just watered
        let zzPlant = Plant(
            name: "ZZ Plant",
            species: "Zamioculcas zamiifolia",
            wateringIntervalDays: 21,
            room: "Office",
            notes: "Extremely low maintenance, shiny leaves"
        )
        zzPlant.lastWateredDate = now
        context.insert(zzPlant)

        // Try to save
        do {
            try context.save()
            print("Successfully seeded \(5) sample plants")
        } catch {
            print("Error seeding sample plants: \(error)")
        }
    }

    /// Mark the first launch as complete
    static func markLaunchComplete() {
        UserDefaults.standard.set(true, forKey: firstLaunchKey)
    }

    /// Reset the first launch flag (useful for testing)
    static func resetFirstLaunchFlag() {
        UserDefaults.standard.set(false, forKey: firstLaunchKey)
    }
}
