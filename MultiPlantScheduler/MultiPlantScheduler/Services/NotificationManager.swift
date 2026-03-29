import UIKit
import UserNotifications
import Foundation

/// Manages local push notifications for watering reminders
class NotificationManager {
    static let shared = NotificationManager()

    private init() {}

    /// Request user permission for notifications
    /// - Returns: true if permission was granted, false otherwise
    func requestPermission() async -> Bool {
        do {
            let granted = try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .sound, .badge])
            if granted {
                await MainActor.run {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
            return granted
        } catch {
            print("Error requesting notification permission: \(error)")
            return false
        }
    }

    /// Schedule a watering reminder notification for a plant
    /// - Parameter plant: The plant to schedule a reminder for
    func scheduleReminder(for plant: Plant) async {
        let content = UNMutableNotificationContent()
        content.title = Constants.Notifications.wateringReminderTitle
        content.body = "\(plant.name) needs watering today"
        content.sound = .default
        content.categoryIdentifier = Constants.Notifications.wateringReminderCategory

        // Safely read badge count on main thread
        let currentBadge: Int = await MainActor.run {
            UIApplication.shared.applicationIconBadgeNumber
        }
        content.badge = NSNumber(value: currentBadge + 1)

        // Add action to the notification
        let waterAction = UNNotificationAction(
            identifier: Constants.Notifications.markWateredAction,
            title: "Mark as Watered",
            options: .foreground
        )
        let dismissAction = UNNotificationAction(
            identifier: Constants.Notifications.dismissAction,
            title: "Dismiss",
            options: []
        )

        let category = UNNotificationCategory(
            identifier: Constants.Notifications.wateringReminderCategory,
            actions: [waterAction, dismissAction],
            intentIdentifiers: [],
            options: []
        )
        UNUserNotificationCenter.current().setNotificationCategories([category])

        // Schedule for 9 AM on the next watering date
        var dateComponents = Calendar.current.dateComponents(
            [.year, .month, .day],
            from: plant.nextWateringDate
        )
        dateComponents.hour = Constants.App.notificationHour
        dateComponents.minute = 0

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        let request = UNNotificationRequest(
            identifier: plant.id.uuidString,
            content: content,
            trigger: trigger
        )

        do {
            try await UNUserNotificationCenter.current().add(request)
            print("Scheduled watering reminder for \(plant.name) on \(plant.nextWateringDate)")
        } catch {
            print("Error scheduling notification for \(plant.name): \(error)")
        }
    }

    /// Cancel a scheduled reminder for a plant
    /// - Parameter plant: The plant to cancel the reminder for
    func cancelReminder(for plant: Plant) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: [plant.id.uuidString]
        )
        print("Cancelled notification for \(plant.name)")
    }

    /// Cancel all pending notifications and reschedule for all plants
    /// - Parameter plants: Array of plants to reschedule reminders for
    func rescheduleAllReminders(plants: [Plant]) async {
        // Cancel all pending notifications
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()

        // Reschedule for each plant
        for plant in plants {
            await scheduleReminder(for: plant)
        }
        print("Rescheduled reminders for all \(plants.count) plants")
    }

    /// Get the count of pending notifications
    /// - Returns: The number of pending notifications
    func getPendingNotificationsCount() async -> Int {
        let requests = await UNUserNotificationCenter.current().pendingNotificationRequests()
        return requests.count
    }

    /// Get all pending notification requests
    /// - Returns: Array of pending UNNotificationRequest objects
    func getPendingNotifications() async -> [UNNotificationRequest] {
        await UNUserNotificationCenter.current().pendingNotificationRequests()
    }
}

// MARK: - Badge Management
extension NotificationManager {
    func clearBadgeCount() {
        UNUserNotificationCenter.current().setBadgeCount(0)
    }
}
