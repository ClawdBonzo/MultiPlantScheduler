import AppIntents
import SwiftData

/// Siri intent: "How many plants do I have?"
struct PlantCountIntent: AppIntent {
    static var title: LocalizedStringResource = "Plant Count"
    static var description = IntentDescription("Returns the number of plants you're tracking")

    func perform() async throws -> some IntentResult & ReturnsValue<String> {
        let container = try SharedContainer.makeModelContainer()
        let context = ModelContext(container)

        let descriptor = FetchDescriptor<Plant>()
        let count = try context.fetchCount(descriptor)

        if count == 0 {
            return .result(value: "You don't have any plants yet. Open Multi Plant to add your first!")
        }

        return .result(value: "You're tracking \(count) plant\(count == 1 ? "" : "s").")
    }
}
