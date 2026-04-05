import SwiftUI
import Foundation

/// App-wide constants for the Multi Plant Watering Schedule app
enum Constants {
    // MARK: - Colors
    enum Colors {
        static let forestGreen = Color(red: 0.133, green: 0.545, blue: 0.133) // #228B22
        static let limeGreen = Color(red: 0.196, green: 0.804, blue: 0.196)   // #32CD32
        static let background = Color(red: 0.059, green: 0.063, blue: 0.063)  // Deeper, cooler dark
        static let textPrimary = Color(red: 0.95, green: 0.96, blue: 0.96)    // Slightly cool white
        static let textSecondary = Color(red: 0.55, green: 0.58, blue: 0.60)  // Cooler grey

        // Urgency colors for watering status
        static let urgencyGood = forestGreen        // >2 days until watering
        static let urgencyWarning = Color(red: 1.0, green: 0.82, blue: 0.28) // Warmer gold
        static let urgencyCritical = Color(red: 1.0, green: 0.32, blue: 0.32) // Rich red
    }

    // MARK: - RevenueCat Configuration
    enum RevenueCat {
        static let apiKey = "appl_iwUIsFniEdnILPWkxeuJvgzLpuJ"
        static let premiumEntitlementID = "premium"
    }

    // MARK: - Subscription Limits
    enum Subscription {
        static let freeTierPlantLimit = 3
        static let monthlyPrice = 3.99
        static let yearlyPrice = 29.99
        static let lifetimePrice = 49.99
        static let freeTierDescription = String(format: NSLocalizedString("Track up to %d plants + 5 free cloud IDs", comment: "Free tier description"), freeTierPlantLimit)
        static let premiumDescription = "Unlimited plants, advanced features"
    }

    // MARK: - Notification Categories
    enum Notifications {
        static let wateringReminderCategory = "WATERING_REMINDER"
        static let markWateredAction = "MARK_WATERED_ACTION"
        static let dismissAction = "DISMISS_ACTION"
        static let wateringReminderTitle = NSLocalizedString("💧 Time to water!", comment: "Notification title for watering reminder")
    }

    // MARK: - Diagnosis Configuration
    enum Diagnosis {
        static let freeDiagnosisLimit = 3
        static let premiumDescription = "Unlimited disease & pest scans"
    }

    // MARK: - App Configuration
    enum App {
        static let appName = "Multi Plant Watering Schedule"
        static let minimumWateringInterval = 1  // Minimum days between waterings
        static let defaultWateringInterval = 7   // Default interval in days
        static let notificationHour = 9          // 9 AM daily reminders
        static let jpegCompressionQuality: CGFloat = 0.7
        static let freePlantLimit = Subscription.freeTierPlantLimit

        // UserDefaults keys for custom notification time
        static let globalNotificationHourKey = "globalNotificationHour"
        static let globalNotificationMinuteKey = "globalNotificationMinute"
    }
}

// MARK: - Convenience Accessors (used throughout all views)
/// Shorthand for Constants.Colors — used in all views
typealias AppColors = Constants.Colors
/// Shorthand for Constants.App
typealias AppConfig = Constants.App
/// Shorthand for Constants.Subscription
typealias AppSubscription = Constants.Subscription

// Add urgency color aliases to match view usage
extension Constants.Colors {
    static let urgencyGreen = urgencyGood
    static let urgencyYellow = urgencyWarning
    static let urgencyRed = urgencyCritical
}

// MARK: - SwiftUI Color Extensions
extension Color {
    /// Forest green accent color for the app theme
    static let plantGreen = Constants.Colors.forestGreen

    /// Primary background color (dark theme)
    static let appBackground = Constants.Colors.background
}
