import SwiftUI

/// App-wide constants for the Multi Plant Watering Schedule app
enum Constants {
    // MARK: - Colors
    enum Colors {
        static let forestGreen = Color(red: 0.133, green: 0.545, blue: 0.133) // #228B22
        static let limeGreen = Color(red: 0.196, green: 0.804, blue: 0.196)   // #32CD32
        static let background = Color(red: 0.071, green: 0.071, blue: 0.071)  // #121212
        static let textPrimary = Color(red: 0.961, green: 0.961, blue: 0.961) // #F5F5F5
        static let textSecondary = Color(red: 0.627, green: 0.627, blue: 0.627) // #A0A0A0

        // Urgency colors for watering status
        static let urgencyGood = forestGreen        // >2 days until watering
        static let urgencyWarning = Color.yellow   // 1-2 days until watering
        static let urgencyCritical = Color.red     // Overdue or due today
    }

    // MARK: - RevenueCat Configuration
    enum RevenueCat {
        static let apiKey = "YOUR_REVENUECAT_API_KEY_HERE"
        static let premiumEntitlementID = "premium"
    }

    // MARK: - Subscription Limits
    enum Subscription {
        static let freeTierPlantLimit = 5
        static let monthlyPrice = 4.99
        static let yearlyPrice = 39.99
        static let freeTierDescription = "Track up to \(freeTierPlantLimit) plants"
        static let premiumDescription = "Unlimited plants, advanced features"
    }

    // MARK: - Notification Categories
    enum Notifications {
        static let wateringReminderCategory = "WATERING_REMINDER"
        static let markWateredAction = "MARK_WATERED_ACTION"
        static let dismissAction = "DISMISS_ACTION"
        static let wateringReminderTitle = "💧 Time to water!"
    }

    // MARK: - App Configuration
    enum App {
        static let appName = "Multi Plant Watering Schedule"
        static let minimumWateringInterval = 1  // Minimum days between waterings
        static let defaultWateringInterval = 7   // Default interval in days
        static let notificationHour = 9          // 9 AM daily reminders
        static let jpegCompressionQuality: CGFloat = 0.7
        static let freePlantLimit = Subscription.freeTierPlantLimit
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
