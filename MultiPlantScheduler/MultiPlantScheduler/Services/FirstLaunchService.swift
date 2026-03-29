import SwiftData
import Foundation

/// Handles first launch setup — no longer seeds sample data
enum FirstLaunchService {
    private static let firstLaunchKey = "com.multiplantwateringschedule.firstLaunchComplete"

    /// Check if this is the first launch of the app
    static var isFirstLaunch: Bool {
        !UserDefaults.standard.bool(forKey: firstLaunchKey)
    }

    /// Mark the first launch as complete
    static func markLaunchComplete() {
        UserDefaults.standard.set(true, forKey: firstLaunchKey)
    }

    /// Reset the first launch flag (useful for testing)
    static func resetFirstLaunchFlag() {
        UserDefaults.standard.set(false, forKey: firstLaunchKey)
    }
}
