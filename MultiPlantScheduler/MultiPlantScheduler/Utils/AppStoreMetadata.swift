import Foundation

/// App Store metadata and marketing copy for Multi Plant Watering Schedule
struct AppStoreMetadata {
    static let appTitle = "Multi Plant Watering Schedule"

    static let appSubtitle = "30+ Plants • Offline Reminders"

    static let appDescription = """
    Multi Plant Watering Schedule is your ultimate plant care companion. Track unlimited houseplants, succulents, orchids, and more with smart watering reminders that adjust automatically by season.

    FEATURES:
    • Track 30+ plants offline — no internet required
    • Smart watering reminders that adjust for spring, summer, fall, and winter
    • Beautiful dark-themed interface designed for plant lovers
    • Detailed care logs for each plant
    • Photo library for your plant collection
    • Room-based organization (living room, bedroom, kitchen, bathroom, office, balcony)
    • Watering streaks to track consistency
    • Seasonal watering adjustments based on your location's climate
    • Premium export feature to backup your care history
    • Completely offline-first — your plant data stays on your device

    PERFECT FOR:
    • Beginners learning plant care
    • Experienced plant parents with large collections
    • Tracking fertilizing schedules
    • Recording humidity misting and repotting events
    • Monitoring plant health over time

    SMART FEATURES:
    • Seasonal auto-adjust calculates optimal watering intervals for each season
    • Urgency badges show plants needing water today vs. upcoming
    • Dark mode optimized for nighttime care
    • Haptic feedback for satisfying interactions
    • Quick action buttons for watering, fertilizing, misting, and repotting
    • Care timeline showing your plant care history

    PREMIUM BENEFITS:
    • Unlimited plants (free plan: 3 plants)
    • Export care history as CSV
    • Priority features and early access
    • Full seasonal adjustments
    • $3.99/month, $29.99/year (save 37%), or $49.99 lifetime

    Your plants deserve the best care. Start tracking with Multi Plant Watering Schedule today!

    Privacy Note: All your plant data is stored locally on your device. We never access or upload your personal information to our servers.

    DISCLAIMER: This app is a tracking and reminder tool. Plant care needs vary by species, climate, light, and soil type. Always consult care guides or local nurseries for specific care instructions. This app cannot be held responsible for plant health outcomes.
    """

    static let keywords = "plant care, watering schedule, houseplant tracker, plant reminder, succulent care, indoor plants, plant organizer, garden tracker, care log, seasonal watering"

    static let supportEmail = "support@multiplant.app"

    static let privacyPolicyURL = "https://example.com/privacy"

    static let termsOfServiceURL = "https://example.com/terms"

    static let websiteURL = "https://example.com"

    static let screenshotCaptions = [
        "Dashboard: Track all your plants at a glance with urgent watering status",
        "Plant Details: View complete care history and quick action buttons",
        "Smart Reminders: Get notifications when your plants need water",
        "Care Logs: Track every watering, fertilizing, and misting event",
        "Dark Theme: Beautiful, eye-friendly interface designed for plant lovers",
        "Seasonal Adjust: Watering intervals automatically adjust by season"
    ]

    static let releaseNotes = """
    Version 1.0 - Initial Release
    • Beautiful dark-themed plant tracker app
    • Track unlimited plants with detailed care information
    • Smart watering reminders with seasonal auto-adjust
    • Offline-first architecture — no internet required
    • Photo library and care logs for each plant
    • Room-based organization
    • Premium subscription for extended features
    • Fully optimized dark mode interface
    """

    static var rateAppURL: URL? {
        URL(string: "https://apps.apple.com/app/multi-plant-watering-schedule/id123456789?action=write-review")
    }

    static var appStoreURL: URL? {
        URL(string: "https://apps.apple.com/app/multi-plant-watering-schedule/id123456789")
    }
}
