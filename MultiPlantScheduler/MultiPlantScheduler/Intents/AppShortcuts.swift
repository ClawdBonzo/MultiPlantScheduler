import AppIntents

/// Registers Siri shortcuts for the app
struct MultiPlantShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: PlantsNeedingWaterIntent(),
            phrases: [
                "Which plants need water in \(.applicationName)",
                "What needs watering in \(.applicationName)",
                "Check my plants in \(.applicationName)"
            ],
            shortTitle: "Plants Needing Water",
            systemImageName: "drop.fill"
        )

        AppShortcut(
            intent: WaterPlantIntent(),
            phrases: [
                "Water a plant in \(.applicationName)",
                "Mark a plant as watered in \(.applicationName)"
            ],
            shortTitle: "Water a Plant",
            systemImageName: "drop.circle.fill"
        )

        AppShortcut(
            intent: PlantCountIntent(),
            phrases: [
                "How many plants in \(.applicationName)",
                "Count my plants in \(.applicationName)"
            ],
            shortTitle: "Plant Count",
            systemImageName: "leaf.fill"
        )
    }
}
