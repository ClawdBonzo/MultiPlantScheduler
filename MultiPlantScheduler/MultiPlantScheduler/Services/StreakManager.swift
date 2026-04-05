import Foundation
import SwiftUI
import SwiftData
import Combine

/// Manages the global daily care streak — persisted in UserDefaults with SwiftData backup
final class StreakManager: ObservableObject {
    static let shared = StreakManager()

    // MARK: - UserDefaults Keys
    private let currentStreakKey = "globalCareStreak"
    private let longestStreakKey = "globalLongestStreak"
    private let lastCareKey = "lastCareDateString"         // "yyyy-MM-dd"
    private let streakHistoryKey = "streakMilestoneHistory" // JSON array of milestone dates
    private let totalCareDaysKey = "totalCareDaysCount"

    @Published var currentStreak: Int = 0
    @Published var longestStreak: Int = 0
    @Published var showMilestoneCelebration: Bool = false
    @Published var milestoneReached: Int = 0

    private let calendar = Calendar.current
    private lazy var dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()

    // Milestones that trigger celebrations
    static let milestones = [3, 7, 14, 21, 30, 60, 90, 180, 365]

    private init() {
        currentStreak = UserDefaults.standard.integer(forKey: currentStreakKey)
        longestStreak = UserDefaults.standard.integer(forKey: longestStreakKey)
        checkStreakContinuity()
    }

    // MARK: - Today's date string

    private var todayString: String {
        dateFormatter.string(from: Date.now)
    }

    private var yesterdayString: String {
        let yesterday = calendar.date(byAdding: .day, value: -1, to: Date.now)!
        return dateFormatter.string(from: yesterday)
    }

    // MARK: - Streak Logic

    /// Call when any care action is performed (water, fertilize, etc.)
    func recordCareAction() {
        let lastDate = UserDefaults.standard.string(forKey: lastCareKey) ?? ""

        if lastDate == todayString {
            // Already logged today — no change
            return
        }

        if lastDate == yesterdayString {
            // Consecutive day — extend streak
            currentStreak += 1
        } else if lastDate.isEmpty {
            // First ever care
            currentStreak = 1
        } else {
            // Streak broken — restart
            currentStreak = 1
        }

        // Update longest
        if currentStreak > longestStreak {
            longestStreak = currentStreak
            UserDefaults.standard.set(longestStreak, forKey: longestStreakKey)
        }

        // Increment total care days
        let total = UserDefaults.standard.integer(forKey: totalCareDaysKey) + 1
        UserDefaults.standard.set(total, forKey: totalCareDaysKey)

        // Persist
        UserDefaults.standard.set(currentStreak, forKey: currentStreakKey)
        UserDefaults.standard.set(todayString, forKey: lastCareKey)

        // Check milestones
        if Self.milestones.contains(currentStreak) {
            milestoneReached = currentStreak
            showMilestoneCelebration = true
            saveMilestone(currentStreak)
        }

        #if DEBUG
        print("🔥 StreakManager — care recorded. Streak: \(currentStreak), longest: \(longestStreak)")
        #endif
    }

    /// Check if streak is still valid (called on app launch)
    private func checkStreakContinuity() {
        let lastDate = UserDefaults.standard.string(forKey: lastCareKey) ?? ""

        if lastDate == todayString || lastDate == yesterdayString {
            // Streak still valid
            return
        }

        if !lastDate.isEmpty && currentStreak > 0 {
            // Streak broken
            #if DEBUG
            print("🔥 StreakManager — streak broken (last: \(lastDate), today: \(todayString))")
            #endif
            currentStreak = 0
            UserDefaults.standard.set(0, forKey: currentStreakKey)
        }
    }

    /// Total days with at least one care action
    var totalCareDays: Int {
        UserDefaults.standard.integer(forKey: totalCareDaysKey)
    }

    /// Care consistency percentage (streak / days since first care)
    var consistencyPercent: Double {
        let total = totalCareDays
        guard total > 0 else { return 0 }
        let lastDate = UserDefaults.standard.string(forKey: lastCareKey) ?? ""
        guard !lastDate.isEmpty else { return 0 }
        // Simple: total days cared / days since first use
        let daysSinceStart = max(totalCareDays, 1)
        // Cap at 100%
        return min(Double(total) / Double(daysSinceStart) * 100, 100)
    }

    // MARK: - Milestone History

    private func saveMilestone(_ milestone: Int) {
        var history = milestoneHistory
        let entry = "\(milestone):\(todayString)"
        if !history.contains(entry) {
            history.append(entry)
            if let data = try? JSONEncoder().encode(history) {
                UserDefaults.standard.set(data, forKey: streakHistoryKey)
            }
        }
    }

    var milestoneHistory: [String] {
        guard let data = UserDefaults.standard.data(forKey: streakHistoryKey),
              let history = try? JSONDecoder().decode([String].self, from: data) else {
            return []
        }
        return history
    }

    /// Next milestone to reach
    var nextMilestone: Int? {
        Self.milestones.first { $0 > currentStreak }
    }

    /// Days until next milestone
    var daysToNextMilestone: Int? {
        guard let next = nextMilestone else { return nil }
        return next - currentStreak
    }

    #if DEBUG
    func resetAll() {
        UserDefaults.standard.removeObject(forKey: currentStreakKey)
        UserDefaults.standard.removeObject(forKey: longestStreakKey)
        UserDefaults.standard.removeObject(forKey: lastCareKey)
        UserDefaults.standard.removeObject(forKey: streakHistoryKey)
        UserDefaults.standard.removeObject(forKey: totalCareDaysKey)
        currentStreak = 0
        longestStreak = 0
        print("🔥 StreakManager — reset all data")
    }
    #endif
}
