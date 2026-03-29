import SwiftData
import UIKit
import SwiftUI
import Foundation

/// A houseplant tracked in the app with watering schedule and care history
@Model
final class Plant {
    var id: UUID = UUID()
    var name: String = ""
    var species: String?
    var wateringIntervalDays: Int = 7
    var lastWateredDate: Date?
    var lastFertilizedDate: Date?
    var photoData: Data?  // Compressed JPEG data
    var room: String?
    var notes: String?
    var fertilizerType: String?
    var createdAt: Date = Date.now
    var wateringStreak: Int = 0

    // Health tracking
    var healthStatus: String?
    var lastHealthCheckDate: Date?

    // Custom notification time
    var preferredNotificationHour: Int?
    var preferredNotificationMinute: Int?

    @Relationship(deleteRule: .cascade, inverse: \CareLog.plant)
    var careLogs: [CareLog] = []

    @Relationship(deleteRule: .cascade, inverse: \HealthEntry.plant)
    var healthEntries: [HealthEntry] = []

    @Relationship(deleteRule: .cascade, inverse: \PhotoEntry.plant)
    var photoEntries: [PhotoEntry] = []

    init(
        name: String,
        species: String? = nil,
        wateringIntervalDays: Int = Constants.App.defaultWateringInterval,
        room: String? = nil,
        notes: String? = nil,
        fertilizerType: String? = nil,
        photoData: Data? = nil
    ) {
        self.id = UUID()
        self.name = name
        self.species = species
        self.wateringIntervalDays = max(wateringIntervalDays, Constants.App.minimumWateringInterval)
        self.lastWateredDate = nil
        self.lastFertilizedDate = nil
        self.photoData = photoData
        self.room = room
        self.notes = notes
        self.fertilizerType = fertilizerType
        self.createdAt = Date.now
        self.wateringStreak = 0
    }

    // MARK: - Computed Properties

    /// The next date this plant needs watering
    var nextWateringDate: Date {
        if let lastWatered = lastWateredDate {
            return lastWatered.addingTimeInterval(Double(wateringIntervalDays) * 86400)
        } else {
            return createdAt.addingTimeInterval(Double(wateringIntervalDays) * 86400)
        }
    }

    /// Number of days until the plant needs watering (negative = overdue)
    var daysUntilWatering: Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date.now)
        let nextDate = calendar.startOfDay(for: nextWateringDate)
        let components = calendar.dateComponents([.day], from: today, to: nextDate)
        return components.day ?? 0
    }

    /// Color reflecting watering urgency
    var urgencyColor: Color {
        let days = daysUntilWatering
        if days < 0 || days == 0 {
            return Constants.Colors.urgencyCritical // Red: overdue or due today
        } else if days <= 2 {
            return Constants.Colors.urgencyWarning // Yellow: 1-2 days
        } else {
            return Constants.Colors.urgencyGood // Green: >2 days
        }
    }

    /// Whether the plant is past its next watering date
    var isOverdue: Bool {
        daysUntilWatering < 0
    }

    /// Whether the plant needs watering today
    var isDueToday: Bool {
        daysUntilWatering == 0
    }

    /// SwiftUI Image from photo data, or nil if no photo stored
    var photoImage: Image? {
        guard let photoData = photoData,
              let uiImage = UIImage(data: photoData) else {
            return nil
        }
        return Image(uiImage: uiImage)
    }

    /// Parsed health status from stored string
    var currentHealth: HealthStatus {
        guard let healthStatus = healthStatus else { return .unknown }
        return HealthStatus(rawValue: healthStatus) ?? .unknown
    }

    /// Whether a health check is due (no check or last check > 14 days ago)
    var isHealthCheckDue: Bool {
        guard let lastCheck = lastHealthCheckDate else { return true }
        let daysSinceCheck = Calendar.current.dateComponents([.day], from: lastCheck, to: Date.now).day ?? 0
        return daysSinceCheck >= 14
    }
}

// MARK: - Sample Data for Preview
struct PlantData {
    static let monstera = Plant(
        name: "Monstera",
        species: "Monstera Deliciosa",
        wateringIntervalDays: 7,
        room: "Living Room",
        notes: "Near the window, grows quickly"
    )

    static let snakePlant = Plant(
        name: "Snake Plant",
        species: "Sansevieria trifasciata",
        wateringIntervalDays: 14,
        room: "Bedroom",
        notes: "Very hardy, drought tolerant"
    )

    static let pothos = Plant(
        name: "Pothos",
        species: "Epipremnum aureum",
        wateringIntervalDays: 10,
        room: "Office",
        notes: "Trailing vine, easy care"
    )

    static let fiddleLeafFig = Plant(
        name: "Fiddle Leaf Fig",
        species: "Ficus lyrata",
        wateringIntervalDays: 7,
        room: "Living Room",
        notes: "Prefers bright light, can be finicky"
    )

    static let zzPlant = Plant(
        name: "ZZ Plant",
        species: "Zamioculcas zamiifolia",
        wateringIntervalDays: 21,
        room: "Office",
        notes: "Extremely low maintenance, shiny leaves"
    )

    static var allSamples: [Plant] {
        [monstera, snakePlant, pothos, fiddleLeafFig, zzPlant]
    }
}
