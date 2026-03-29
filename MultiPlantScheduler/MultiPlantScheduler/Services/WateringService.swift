import SwiftData
import WidgetKit

/// Shared watering and care logic used by views, notification actions, and Siri intents
enum WateringService {

    /// Mark a plant as watered, update streak, create care log, and reschedule notifications
    static func markAsWatered(plant: Plant, context: ModelContext) {
        let wasOnTime = !plant.isOverdue
        plant.lastWateredDate = Date.now
        plant.wateringStreak = wasOnTime ? plant.wateringStreak + 1 : 1

        let careLog = CareLog(careType: CareType.water.rawValue, plant: plant)
        plant.careLogs.append(careLog)

        try? context.save()

        Task {
            await NotificationManager.shared.scheduleReminder(for: plant)
        }

        WidgetCenter.shared.reloadAllTimelines()
    }

    /// Perform any care action on a plant
    static func performCare(type: CareType, plant: Plant, context: ModelContext) {
        switch type {
        case .water:
            markAsWatered(plant: plant, context: context)
            return
        case .fertilize:
            plant.lastFertilizedDate = Date.now
        case .mist, .repot:
            break
        }

        let careLog = CareLog(careType: type.rawValue, plant: plant)
        plant.careLogs.append(careLog)

        try? context.save()

        WidgetCenter.shared.reloadAllTimelines()
    }
}
