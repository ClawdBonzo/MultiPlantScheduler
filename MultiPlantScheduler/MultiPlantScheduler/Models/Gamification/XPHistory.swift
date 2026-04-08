import SwiftData
import Foundation

/// Tracks XP gains for analytics and celebration moments
@Model
final class XPHistory {
    var id: UUID
    var xpAmount: Int
    var xpSource: XPSource
    var earnedAt: Date
    var relatedPlantId: UUID?
    var relatedQuestId: UUID?

    var profile: GamificationProfile?

    init(
        xpAmount: Int,
        source: XPSource,
        plantId: UUID? = nil,
        questId: UUID? = nil
    ) {
        self.id = UUID()
        self.xpAmount = xpAmount
        self.xpSource = source
        self.earnedAt = Date.now
        self.relatedPlantId = plantId
        self.relatedQuestId = questId
    }
}

enum XPSource: String, Codable {
    case wateringPlant
    case completingQuest
    case healthCheck
    case diagnosis
    case communityTip
    case streakMilestone
    case badgeUnlock
    case levelUp
    case perfectDay

    var description: String {
        switch self {
        case .wateringPlant: return "Watered a plant"
        case .completingQuest: return "Quest completed"
        case .healthCheck: return "Health check performed"
        case .diagnosis: return "Plant diagnosed"
        case .communityTip: return "Community contribution"
        case .streakMilestone: return "Streak milestone"
        case .badgeUnlock: return "Badge unlocked"
        case .levelUp: return "Level up!"
        case .perfectDay: return "Perfect care day"
        }
    }

    var baseXP: Int {
        switch self {
        case .wateringPlant: return 10
        case .completingQuest: return 25
        case .healthCheck: return 15
        case .diagnosis: return 20
        case .communityTip: return 30
        case .streakMilestone: return 50
        case .badgeUnlock: return 40
        case .levelUp: return 100
        case .perfectDay: return 35
        }
    }
}
