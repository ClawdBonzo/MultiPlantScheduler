import AppIntents
import SwiftData

/// Siri intent: "Which plants need water today?"
struct PlantsNeedingWaterIntent: AppIntent {
    static var title: LocalizedStringResource = "Plants Needing Water"
    static var description = IntentDescription("Lists plants that need watering today or are overdue")

    func perform() async throws -> some IntentResult & ReturnsValue<String> {
        let container = try SharedContainer.makeModelContainer()
        let context = ModelContext(container)

        let descriptor = FetchDescriptor<Plant>()
        let plants = try context.fetch(descriptor)

        let duePlants = plants.filter { $0.isDueToday || $0.isOverdue }
            .sorted { $0.daysUntilWatering < $1.daysUntilWatering }

        if duePlants.isEmpty {
            return .result(value: "All your plants are happy! No watering needed today.")
        }

        let plantList = duePlants.map { plant in
            if plant.isOverdue {
                return "\(plant.name) (overdue by \(abs(plant.daysUntilWatering)) days)"
            } else {
                return "\(plant.name) (due today)"
            }
        }.joined(separator: ", ")

        return .result(value: "\(duePlants.count) plant\(duePlants.count == 1 ? "" : "s") need\(duePlants.count == 1 ? "s" : "") water: \(plantList)")
    }
}
