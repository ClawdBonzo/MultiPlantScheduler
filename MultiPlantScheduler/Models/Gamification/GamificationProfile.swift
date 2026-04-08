import SwiftData
import Foundation

/// User's gamification profile: XP, levels, streaks, badges
@Model
final class GamificationProfile {
    var id: UUID = UUID()
    var currentXP: Int = 0
    var totalXPEarned: Int = 0
    var currentLevel: Int = 1
    var levelName: String = "Seedling"

    // Streaks
    var dailyStreak: Int = 0
    var longestDailyStreak: Int = 0
    var lastStreakDate: Date?
    var streakMultiplier: Float = 1.0

    // Tracking
    var createdAt: Date = Date.now
    var lastXPEarnedDate: Date?
    var totalQuestsCompleted: Int = 0
    var totalBadgesUnlocked: Int = 0

    // Collections
    @Relationship(deleteRule: .cascade, inverse: \Quest.profile)
    var quests: [Quest] = []

    @Relationship(deleteRule: .cascade, inverse: \UnlockedBadge.profile)
    var badges: [UnlockedBadge] = []

    @Relationship(deleteRule: .cascade, inverse: \VisualProgression.profile)
    var plantProgressions: [VisualProgression] = []

    @Relationship(deleteRule: .cascade, inverse: \XPHistory.profile)
    var xpHistory: [XPHistory] = []

    init() {
        self.id = UUID()
        self.createdAt = Date.now
    }

    // MARK: - Level Calculations

    var xpForNextLevel: Int {
        let baseXP = 100
        let multiplier = currentLevel
        return baseXP * multiplier
    }

    var xpProgress: Double {
        let needed = xpForNextLevel
        return Double(currentXP) / Double(needed)
    }

    var xpProgressPercent: Int {
        Int(xpProgress * 100)
    }

    // MARK: - Level Names

    static func levelName(for level: Int) -> String {
        let names = [
            "Seedling", "Sprout", "Young Plant", "Growing Gardener",
            "Plant Parent", "Master Gardener", "Botanical Expert", "Plant Whisperer",
            "Greenhouse Master", "Legendary Cultivator"
        ]
        if level <= names.count {
            return names[level - 1]
        }
        return "Legendary Cultivator \(level - 9)"
    }

    // MARK: - Streak Management

    func updateDailyStreak() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date.now)

        if let lastDate = lastStreakDate {
            let lastDay = calendar.startOfDay(for: lastDate)
            let components = calendar.dateComponents([.day], from: lastDay, to: today)

            if components.day == 0 {
                // Already updated today
                return
            } else if components.day == 1 {
                // Consecutive day
                dailyStreak += 1
                updateStreakMultiplier()
            } else {
                // Streak broken
                if dailyStreak > longestDailyStreak {
                    longestDailyStreak = dailyStreak
                }
                dailyStreak = 1
                streakMultiplier = 1.0
            }
        } else {
            // First streak
            dailyStreak = 1
            streakMultiplier = 1.0
        }

        lastStreakDate = Date.now
    }

    private func updateStreakMultiplier() {
        switch dailyStreak {
        case 3: streakMultiplier = 1.1
        case 7: streakMultiplier = 1.2
        case 14: streakMultiplier = 1.3
        case 30: streakMultiplier = 1.5
        case 60: streakMultiplier = 1.7
        case 100: streakMultiplier = 2.0
        default:
            if dailyStreak > 100 && dailyStreak % 50 == 0 {
                streakMultiplier = min(2.0 + Float(dailyStreak - 100) / 100, 3.0)
            }
        }
    }
}
