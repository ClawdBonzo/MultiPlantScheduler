import SwiftData
import Foundation

/// A health check-in record for tracking plant wellbeing over time
@Model
final class HealthEntry {
    var id: UUID = UUID()
    var date: Date = Date.now
    var status: String = "unknown"  // HealthStatus.rawValue
    var notes: String?
    var plant: Plant?

    init(
        status: HealthStatus,
        date: Date = Date.now,
        notes: String? = nil,
        plant: Plant? = nil
    ) {
        self.id = UUID()
        self.date = date
        self.status = status.rawValue
        self.notes = notes
        self.plant = plant
    }

    /// Parsed health status
    var healthStatus: HealthStatus {
        HealthStatus(rawValue: status) ?? .unknown
    }
}
