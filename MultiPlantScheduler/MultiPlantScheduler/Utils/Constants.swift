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

    // MARK: - Subscription Limits & Tiers (4-Tier Modern System)
    enum Subscription {
        static let freeTierPlantLimit = 3
        static let freeTierDiagnosisLimit = 3

        // Trial Configuration
        static let trialDays = 3
        static let trialPrice = 0.0

        // Subscription Tiers
        enum Tier: String {
            case basic = "basic_monthly"
            case pro = "pro_monthly"
            case max = "max_monthly"
            case premium = "premium_annual"

            var displayName: String {
                switch self {
                case .basic: return "Basic"
                case .pro: return "Pro"
                case .max: return "Max"
                case .premium: return "Premium+"
                }
            }

            var price: String {
                switch self {
                case .basic: return "$2.99"
                case .pro: return "$5.99"
                case .max: return "$9.99"
                case .premium: return "$79.99"
                }
            }

            var period: String {
                switch self {
                case .basic, .pro, .max: return "/month"
                case .premium: return "/year"
                }
            }

            var features: [String] {
                switch self {
                case .basic:
                    return [
                        "Up to 5 plants",
                        "Basic reminders",
                        "Community access",
                        "5 free AI scans/month"
                    ]
                case .pro:
                    return [
                        "Unlimited plants",
                        "AI diagnosis (10/month)",
                        "Advanced analytics",
                        "Priority community"
                    ]
                case .max:
                    return [
                        "Everything in Pro",
                        "Unlimited diagnosis",
                        "Priority support",
                        "Exclusive features"
                    ]
                case .premium:
                    return [
                        "Everything in Max",
                        "2+ months free",
                        "Annual discount",
                        "Lifetime updates"
                    ]
                }
            }

            var plantLimit: Int {
                switch self {
                case .basic: return 5
                case .pro, .max, .premium: return 999 // Unlimited
                }
            }

            var diagnosisLimit: Int {
                switch self {
                case .basic: return 5
                case .pro: return 10
                case .max, .premium: return 999 // Unlimited
                }
            }
        }

        // Legacy aliases for compatibility
        static let freeTierDescription = String(format: NSLocalizedString("Track up to %d plants + %d free diagnoses", comment: "Free tier description"), freeTierPlantLimit, freeTierDiagnosisLimit)
        static let premiumDescription = "Premium features: unlimited plants, advanced analytics, priority support"
        static let monthlyPrice = 5.99
        static let yearlyPrice = 59.99
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
