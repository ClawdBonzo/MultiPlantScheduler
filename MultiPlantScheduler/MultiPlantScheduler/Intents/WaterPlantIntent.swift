import AppIntents
import SwiftData

/// Siri intent: "Water my [plant name]"
struct WaterPlantIntent: AppIntent {
    static var title: LocalizedStringResource = "Water a Plant"
    static var description = IntentDescription("Mark a plant as watered")

    @Parameter(title: "Plant Name")
    var plantName: String

    func perform() async throws -> some IntentResult & ReturnsValue<String> {
        let container = try SharedContainer.makeModelContainer()
        let context = ModelContext(container)

        let descriptor = FetchDescriptor<Plant>()
        let plants = try context.fetch(descriptor)

        // Find plant by case-insensitive name match
        guard let plant = plants.first(where: {
            $0.name.localizedCaseInsensitiveCompare(plantName) == .orderedSame
        }) else {
            let available = plants.map(\.name).joined(separator: ", ")
            return .result(value: "Couldn't find a plant named \"\(plantName)\". Your plants: \(available)")
        }

        WateringService.markAsWatered(plant: plant, context: context)

        return .result(value: "Marked \(plant.name) as watered! Next watering in \(plant.wateringIntervalDays) days.")
    }
}
