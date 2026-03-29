import UIKit
import UserNotifications
import SwiftData

/// App delegate handling notification actions and lifecycle events
class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        NotificationManager.shared.registerCategories()
        return true
    }

    // MARK: - Foreground Notification Display

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        return [.banner, .sound, .badge]
    }

    // MARK: - Notification Action Handling

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse
    ) async {
        let actionIdentifier = response.actionIdentifier
        let notificationIdentifier = response.notification.request.identifier

        // Strip "-followup" suffix to get the plant UUID
        let plantIDString = notificationIdentifier.replacingOccurrences(of: "-followup", with: "")

        guard actionIdentifier == Constants.Notifications.markWateredAction else {
            return
        }

        guard let plantID = UUID(uuidString: plantIDString) else {
            print("Invalid plant ID in notification: \(plantIDString)")
            return
        }

        // Mark the plant as watered from the notification action
        do {
            let container = try SharedContainer.makeModelContainer()
            let context = ModelContext(container)

            let descriptor = FetchDescriptor<Plant>(
                predicate: #Predicate<Plant> { $0.id == plantID }
            )
            guard let plant = try context.fetch(descriptor).first else {
                print("Plant not found for ID: \(plantID)")
                return
            }

            WateringService.markAsWatered(plant: plant, context: context)
            print("Marked \(plant.name) as watered from notification action")
        } catch {
            print("Error handling notification action: \(error)")
        }
    }
}
