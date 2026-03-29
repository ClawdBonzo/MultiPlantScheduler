import WidgetKit

/// Lightweight plant data for widget display (avoids loading full @Model objects)
struct WidgetPlantData: Identifiable {
    let id: UUID
    let name: String
    let daysUntilWatering: Int
    let emoji: String

    var urgency: WidgetUrgency {
        if daysUntilWatering < 0 || daysUntilWatering == 0 {
            return .critical
        } else if daysUntilWatering <= 2 {
            return .warning
        } else {
            return .good
        }
    }

    var statusText: String {
        if daysUntilWatering < 0 {
            return "Overdue \(abs(daysUntilWatering))d"
        } else if daysUntilWatering == 0 {
            return "Due today"
        } else {
            return "In \(daysUntilWatering)d"
        }
    }
}

enum WidgetUrgency {
    case critical, warning, good
}

/// Timeline entry for plant widgets
struct PlantWidgetEntry: TimelineEntry {
    let date: Date
    let plants: [WidgetPlantData]
    let isPremium: Bool

    static var placeholder: PlantWidgetEntry {
        PlantWidgetEntry(
            date: Date(),
            plants: [
                WidgetPlantData(id: UUID(), name: "Monstera", daysUntilWatering: 0, emoji: "🌿"),
                WidgetPlantData(id: UUID(), name: "Snake Plant", daysUntilWatering: 3, emoji: "🌱"),
                WidgetPlantData(id: UUID(), name: "Pothos", daysUntilWatering: -1, emoji: "🪴"),
            ],
            isPremium: true
        )
    }
}
