import UIKit
import UserNotifications
import UIKit

/// Manages local push notifications for watering reminders
class NotificationManager {
    static let shared = NotificationManager()

    private init() {}

    // MARK: - Categories

    /// Register notification categories and actions — call once from AppDelegate
    func registerCategories() {
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
    }

    // MARK: - Permissions

    /// Request user permission for notifications
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
            #if DEBUG
            print("Error requesting notification permission: \(error)")
            #endif
            return false
        }
    }

    // MARK: - Badge Management

    /// Clear the app badge count
    func clearBadgeCount() {
        let center = UNUserNotificationCenter.current()
        center.setBadgeCount(0)
        center.removeAllDeliveredNotifications()
    }

    // MARK: - Scheduling

    /// Resolve the notification hour/minute for a plant
    private func notificationTime(for plant: Plant) -> (hour: Int, minute: Int) {
        // Per-plant override (premium)
        if let hour = plant.preferredNotificationHour {
            return (hour, plant.preferredNotificationMinute ?? 0)
        }
        // Global user preference
        let defaults = UserDefaults.standard
        let globalHour = defaults.object(forKey: Constants.App.globalNotificationHourKey) as? Int
        if let globalHour = globalHour {
            let globalMinute = defaults.integer(forKey: Constants.App.globalNotificationMinuteKey)
            return (globalHour, globalMinute)
        }
        // Default: 9:00 AM
        return (Constants.App.notificationHour, 0)
    }

    /// Schedule a watering reminder notification for a plant
    func scheduleReminder(for plant: Plant) async {
        let content = UNMutableNotificationContent()
        content.title = Constants.Notifications.wateringReminderTitle
        content.body = "\(plant.name) needs watering today"
        content.sound = .default
        content.categoryIdentifier = Constants.Notifications.wateringReminderCategory
        content.badge = 1

        let time = notificationTime(for: plant)

        // Schedule for the configured time on the next watering date
        var dateComponents = Calendar.current.dateComponents(
            [.year, .month, .day],
            from: plant.nextWateringDate
        )
        dateComponents.hour = time.hour
        dateComponents.minute = time.minute

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        let request = UNNotificationRequest(
            identifier: plant.id.uuidString,
            content: content,
            trigger: trigger
        )

        do {
            try await UNUserNotificationCenter.current().add(request)
            #if DEBUG
            print("Scheduled watering reminder for \(plant.name) on \(plant.nextWateringDate) at \(time.hour):\(String(format: "%02d", time.minute))")
            #endif
        } catch {
            #if DEBUG
            print("Error scheduling notification for \(plant.name): \(error)")
            #endif
        }

        // Also schedule a follow-up reminder for the next day in case they miss it
        await scheduleFollowUpReminder(for: plant, time: time)
    }

    /// Schedule a follow-up reminder for the day after the watering date
    private func scheduleFollowUpReminder(for plant: Plant, time: (hour: Int, minute: Int)) async {
        let followUpDate = Calendar.current.date(
            byAdding: .day, value: 1, to: plant.nextWateringDate
        ) ?? plant.nextWateringDate

        let content = UNMutableNotificationContent()
        content.title = "🚨 \(plant.name) still needs water!"
        content.body = "Don't forget — \(plant.name) was due for watering yesterday"
        content.sound = .default
        content.categoryIdentifier = Constants.Notifications.wateringReminderCategory
        content.badge = 1

        var dateComponents = Calendar.current.dateComponents(
            [.year, .month, .day],
            from: followUpDate
        )
        dateComponents.hour = time.hour
        dateComponents.minute = time.minute

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        let request = UNNotificationRequest(
            identifier: "\(plant.id.uuidString)-followup",
            content: content,
            trigger: trigger
        )

        do {
            try await UNUserNotificationCenter.current().add(request)
        } catch {
            #if DEBUG
            print("Error scheduling follow-up for \(plant.name): \(error)")
            #endif
        }
    }

    // MARK: - Cancellation

    /// Cancel a scheduled reminder and its follow-up for a plant
    func cancelReminder(for plant: Plant) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: [plant.id.uuidString, "\(plant.id.uuidString)-followup"]
        )
        #if DEBUG
        print("Cancelled notification for \(plant.name)")
        #endif
    }

    /// Cancel all pending notifications and reschedule for all plants
    func rescheduleAllReminders(plants: [Plant]) async {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()

        for plant in plants {
            await scheduleReminder(for: plant)
        }
        #if DEBUG
        print("Rescheduled reminders for all \(plants.count) plants")
        #endif
    }

    // MARK: - Queries

    /// Get the count of pending notifications
    func getPendingNotificationsCount() async -> Int {
        let requests = await UNUserNotificationCenter.current().pendingNotificationRequests()
        return requests.count
    }

    /// Get all pending notification requests
    func getPendingNotifications() async -> [UNNotificationRequest] {
        await UNUserNotificationCenter.current().pendingNotificationRequests()
    }
}
