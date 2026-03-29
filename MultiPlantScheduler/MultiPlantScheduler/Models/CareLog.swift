import SwiftData
import SwiftUI
import Foundation

/// A record of care activities performed on a plant
@Model
final class CareLog {
    var id: UUID = UUID()
    var logDate: Date = Date.now
    var careType: String = "water"  // Use CareType.rawValue
    var notes: String?
    var plant: Plant?

    init(
        careType: String,
        logDate: Date = Date.now,
        notes: String? = nil,
        plant: Plant? = nil
    ) {
        self.id = UUID()
        self.logDate = logDate
        self.careType = careType
        self.notes = notes
        self.plant = plant
    }
}

// MARK: - Care Type Enum
enum CareType: String, CaseIterable, Codable {
    case water = "water"
    case fertilize = "fertilize"
    case mist = "mist"
    case repot = "repot"

    /// SF Symbol icon name for this care type
    var iconName: String {
        switch self {
        case .water:
            return "drop.fill"
        case .fertilize:
            return "leaf.fill"
        case .mist:
            return "cloud.rain.fill"
        case .repot:
            return "arrow.up.bin.fill"
        }
    }

    /// Human-readable label for this care type
    var label: String {
        switch self {
        case .water:
            return "Watered"
        case .fertilize:
            return "Fertilized"
        case .mist:
            return "Misted"
        case .repot:
            return "Repotted"
        }
    }

    /// Color associated with this care type
    var color: Color {
        switch self {
        case .water:
            return Color.blue
        case .fertilize:
            return Color.green
        case .mist:
            return Color.cyan
        case .repot:
            return Color.orange
        }
    }
}
