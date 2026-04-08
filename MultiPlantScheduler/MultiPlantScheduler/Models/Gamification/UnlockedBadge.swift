import SwiftData
import Foundation

/// A badge earned by the user
@Model
final class UnlockedBadge {
    var id: UUID = UUID()
    var badgeType: BadgeType
    var unlockedDate: Date
    var displayName: String = ""
    var badgeDescription: String = ""
    var emoji: String = "🏆"

    var profile: GamificationProfile?

    init(badgeType: BadgeType) {
        self.id = UUID()
        self.badgeType = badgeType
        self.unlockedDate = Date.now
        self.displayName = badgeType.displayName
        self.badgeDescription = badgeType.badgeDescription
        self.emoji = badgeType.emoji
    }
}

// MARK: - Badge Types

enum BadgeType: String, Codable {
    // Watering badges
    case firstWater
    case waterMaster
    case waterEarned = "water_earned_10"
    case waterEarned50 = "water_earned_50"
    case waterEarned100 = "water_earned_100"

    // Streak badges
    case streakStarted
    case week
    case month
    case perfectCareStreak
    case streakOnFire

    // Health badges
    case firstHealthCheck
    case healthChampion
    case diagnosisExpert
    case rareDiscovery

    // Collection badges
    case firstPlant
    case fivePlants
    case tenPlants
    case botanist

    // Milestone badges
    case levelUp
    case masterGardener
    case communityContributor
    case viralMoment

    var displayName: String {
        switch self {
        case .firstWater: return "Hydration Hero"
        case .waterMaster: return "Water Master"
        case .waterEarned: return "Watering 10 Plants"
        case .waterEarned50: return "Watering 50 Plants"
        case .waterEarned100: return "Watering 100 Plants"

        case .streakStarted: return "On Fire 🔥"
        case .week: return "Week Warrior"
        case .month: return "Monthly Master"
        case .perfectCareStreak: return "Perfect Care Streak"
        case .streakOnFire: return "Unstoppable"

        case .firstHealthCheck: return "Health Inspector"
        case .healthChampion: return "Health Champion"
        case .diagnosisExpert: return "AI Detective"
        case .rareDiscovery: return "Rare Plant Expert"

        case .firstPlant: return "Plant Parent"
        case .fivePlants: return "Growing Garden"
        case .tenPlants: return "Botanical Enthusiast"
        case .botanist: return "Botanist"

        case .levelUp: return "Leveling Up"
        case .masterGardener: return "Master Gardener"
        case .communityContributor: return "Community Star"
        case .viralMoment: return "Viral Sensation"
        }
    }

    var badgeDescription: String {
        switch self {
        case .firstWater: return "Watered your first plant"
        case .waterMaster: return "Watered 5 different plants in one day"
        case .waterEarned: return "Watered 10 plants total"
        case .waterEarned50: return "Watered 50 plants total"
        case .waterEarned100: return "Watered 100 plants total"

        case .streakStarted: return "Started a daily care streak"
        case .week: return "Maintained a 7-day care streak"
        case .month: return "Maintained a 30-day care streak"
        case .perfectCareStreak: return "Never missed a single day"
        case .streakOnFire: return "100+ day care streak"

        case .firstHealthCheck: return "Performed your first health check"
        case .healthChampion: return "Checked plant health 20 times"
        case .diagnosisExpert: return "Used AI diagnosis 10 times"
        case .rareDiscovery: return "Discovered a rare plant"

        case .firstPlant: return "Added your first plant"
        case .fivePlants: return "Collecting 5 plants"
        case .tenPlants: return "Caring for 10 plants"
        case .botanist: return "Master of 20+ plants"

        case .levelUp: return "Reached level 5"
        case .masterGardener: return "Reached Master Gardener level"
        case .communityContributor: return "Shared tips with the community"
        case .viralMoment: return "Earned 100+ likes on a shared moment"
        }
    }

    var emoji: String {
        switch self {
        case .firstWater: return "💧"
        case .waterMaster: return "🌊"
        case .waterEarned, .waterEarned50, .waterEarned100: return "🚿"

        case .streakStarted, .streakOnFire: return "🔥"
        case .week, .month: return "📅"
        case .perfectCareStreak: return "✨"

        case .firstHealthCheck, .healthChampion: return "❤️"
        case .diagnosisExpert: return "🔍"
        case .rareDiscovery: return "🌺"

        case .firstPlant: return "🌱"
        case .fivePlants, .tenPlants: return "🌿"
        case .botanist: return "🌳"

        case .levelUp: return "⬆️"
        case .masterGardener: return "👨‍🌾"
        case .communityContributor: return "👥"
        case .viralMoment: return "⭐"
        }
    }
}
