import SwiftData
import Foundation

/// Tracks visual evolution/growth of plants for gamification
@Model
final class VisualProgression {
    var id: UUID
    var plantId: UUID // Reference to Plant.id
    var currentStage: GrowthStage
    var careQualityScore: Double // 0-100, affects visual appearance
    var flourishLevel: Int // How flourished the plant is (0-3)
    var lastStageUpgradeDate: Date
    var bloomingActive: Bool
    var bloomCount: Int // Number of times bloomed

    var profile: GamificationProfile?

    init(plantId: UUID) {
        self.id = UUID()
        self.plantId = plantId
        self.currentStage = .seedling
        self.careQualityScore = 50
        self.flourishLevel = 0
        self.lastStageUpgradeDate = Date.now
        self.bloomingActive = false
        self.bloomCount = 0
    }

    // MARK: - Stage Progression

    var stageEmoji: String {
        currentStage.emoji
    }

    var stageName: String {
        currentStage.displayName
    }

    func updateCareQuality(delta: Double) {
        careQualityScore = max(0, min(100, careQualityScore + delta))
        checkStageUpgrade()
    }

    private func checkStageUpgrade() {
        let calendar = Calendar.current
        let daysSinceUpgrade = calendar.dateComponents([.day], from: lastStageUpgradeDate, to: Date.now).day ?? 0

        if careQualityScore >= 80 && daysSinceUpgrade >= 7 && currentStage.canUpgrade {
            upgradeStage()
        }
    }

    private func upgradeStage() {
        if let nextStage = currentStage.nextStage {
            currentStage = nextStage
            lastStageUpgradeDate = Date.now
            careQualityScore = max(careQualityScore - 10, 40) // Reset slightly
        }
    }

    func triggerBlooming() {
        bloomingActive = true
        bloomCount += 1
        flourishLevel = min(flourishLevel + 1, 3)
    }

    func endBlooming() {
        bloomingActive = false
    }
}

// MARK: - Growth Stages

enum GrowthStage: String, Codable {
    case seedling
    case sprout
    case growing
    case mature
    case flourishing
    case legendary

    var emoji: String {
        switch self {
        case .seedling: return "🌱"
        case .sprout: return "🌿"
        case .growing: return "🌳"
        case .mature: return "🌲"
        case .flourishing: return "🌺"
        case .legendary: return "🌟"
        }
    }

    var displayName: String {
        switch self {
        case .seedling: return "Seedling"
        case .sprout: return "Sprout"
        case .growing: return "Growing"
        case .mature: return "Mature"
        case .flourishing: return "Flourishing"
        case .legendary: return "Legendary"
        }
    }

    var daysToNext: Int {
        switch self {
        case .seedling: return 7
        case .sprout: return 14
        case .growing: return 21
        case .mature: return 30
        case .flourishing: return 60
        case .legendary: return Int.max
        }
    }

    var canUpgrade: Bool {
        self != .legendary
    }

    var nextStage: GrowthStage? {
        switch self {
        case .seedling: return .sprout
        case .sprout: return .growing
        case .growing: return .mature
        case .mature: return .flourishing
        case .flourishing: return .legendary
        case .legendary: return nil
        }
    }
}
