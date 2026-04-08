import SwiftData
import Foundation

/// Daily/weekly gamification quests for engaging plant care
@Model
final class Quest {
    var id: UUID
    var title: String
    var questDescription: String
    var questType: QuestType
    var category: QuestCategory
    var xpReward: Int
    var progress: Int
    var target: Int
    var isCompleted: Bool
    var completedDate: Date?
    var createdAt: Date
    var expiresAt: Date? // Daily quests expire next day, weekly expire next week

    var profile: GamificationProfile?

    init(
        title: String,
        description: String,
        questType: QuestType,
        category: QuestCategory,
        xpReward: Int,
        target: Int = 1
    ) {
        self.id = UUID()
        self.title = title
        self.questDescription = description
        self.questType = questType
        self.category = category
        self.xpReward = xpReward
        self.target = target
        self.progress = 0
        self.isCompleted = false
        self.createdAt = Date.now

        // Set expiration
        let calendar = Calendar.current
        if questType == .daily {
            self.expiresAt = calendar.date(byAdding: .day, value: 1, to: Date.now)
        } else {
            self.expiresAt = calendar.date(byAdding: .day, value: 7, to: Date.now)
        }
    }

    // MARK: - Progress

    var isExpired: Bool {
        guard let expiresAt = expiresAt else { return false }
        return Date.now > expiresAt
    }

    var progressPercent: Double {
        Double(progress) / Double(max(target, 1))
    }

    func incrementProgress(by amount: Int = 1) {
        if isCompleted { return }

        progress = min(progress + amount, target)

        if progress >= target {
            isCompleted = true
            completedDate = Date.now
        }
    }

    var progressDisplay: String {
        if target == 1 {
            return isCompleted ? "✓" : "0/1"
        }
        return "\(progress)/\(target)"
    }
}

// MARK: - Enums

enum QuestType: Codable {
    case daily
    case weekly
}

enum QuestCategory: Codable {
    case watering
    case health
    case diagnosis
    case community
    case streak
    case collection

    var emoji: String {
        switch self {
        case .watering: return "💧"
        case .health: return "❤️"
        case .diagnosis: return "🔍"
        case .community: return "👥"
        case .streak: return "🔥"
        case .collection: return "🌿"
        }
    }
}
