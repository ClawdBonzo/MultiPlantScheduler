import SwiftUI
import SwiftData
import Combine

/// Central manager for the gamification system
@MainActor
final class GamificationManager: ObservableObject {
    static let shared = GamificationManager()

    // Published properties for UI
    @Published var profile: GamificationProfile?
    @Published var showLevelUpCelebration: Bool = false
    @Published var showBadgeUnlock: (badge: UnlockedBadge, show: Bool) = (badge: UnlockedBadge(badgeType: .firstPlant), show: false)
    @Published var showQuestCompletion: (quest: Quest, show: Bool) = (quest: Quest(title: "", description: "", questType: .daily, category: .watering, xpReward: 0), show: false)
    @Published var showStreakFlame: Bool = false
    @Published var recentXPGain: (amount: Int, source: String) = (0, "")

    private var modelContext: ModelContext?
    private var cancellables = Set<AnyCancellable>()

    private init() {}

    // MARK: - Initialization

    func initialize(with context: ModelContext) {
        self.modelContext = context

        // Load or create profile
        let descriptor = FetchDescriptor<GamificationProfile>()
        if let existing = try? context.fetch(descriptor).first {
            self.profile = existing
        } else {
            let newProfile = GamificationProfile()
            context.insert(newProfile)
            self.profile = newProfile
            saveContext()
        }

        // Check daily streak on launch
        profile?.updateDailyStreak()
        saveContext()
    }

    // MARK: - XP & Leveling

    func addXP(_ amount: Int, source: XPSource, plantId: UUID? = nil, questId: UUID? = nil) {
        guard let profile = profile, let context = modelContext else { return }

        let scaledXP = Int(Float(amount) * profile.streakMultiplier)

        profile.currentXP += scaledXP
        profile.totalXPEarned += scaledXP
        profile.lastXPEarnedDate = Date.now

        // Track history
        let history = XPHistory(xpAmount: scaledXP, source: source, plantId: plantId, questId: questId)
        profile.xpHistory.append(history)
        context.insert(history)

        // Show XP gain
        recentXPGain = (scaledXP, source.description)

        checkLevelUp(in: context)
        saveContext()

        HapticManager.shared.softTap()
    }

    private func checkLevelUp(in context: ModelContext) {
        guard let profile = profile else { return }

        let xpNeeded = profile.xpForNextLevel
        if profile.currentXP >= xpNeeded {
            levelUp(in: context)
        }
    }

    private func levelUp(in context: ModelContext) {
        guard let profile = profile else { return }

        profile.currentLevel += 1
        profile.levelName = GamificationProfile.levelName(for: profile.currentLevel)
        profile.currentXP = 0

        // Trigger celebration
        showLevelUpCelebration = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.showLevelUpCelebration = false
        }

        // Award XP for milestone
        addXP(profile.currentLevel * 10, source: .levelUp)

        // Check for Master Gardener badge (level 10)
        if profile.currentLevel >= 10 {
            unlockBadge(.masterGardener, in: context)
        }

        HapticManager.shared.celebration()
        saveContext()
    }

    // MARK: - Quests

    func generateDailyQuests() {
        guard let profile = profile, let context = modelContext else { return }

        // Remove expired quests
        profile.quests.removeAll { $0.isExpired }

        // Check if we already have today's quests
        let hasDaily = profile.quests.contains { $0.questType == .daily && !$0.isExpired }
        if hasDaily { return }

        let dailyQuests = [
            Quest(
                title: "Water 3 plants",
                description: "Keep your garden hydrated",
                questType: .daily,
                category: .watering,
                xpReward: 30,
                target: 3
            ),
            Quest(
                title: "Perfect care day",
                description: "Complete all recommended care tasks",
                questType: .daily,
                category: .watering,
                xpReward: 40,
                target: 1
            ),
            Quest(
                title: "Health check 2 plants",
                description: "Monitor plant health",
                questType: .daily,
                category: .health,
                xpReward: 25,
                target: 2
            )
        ]

        for quest in dailyQuests {
            context.insert(quest)
            profile.quests.append(quest)
        }

        saveContext()
    }

    func generateWeeklyQuests() {
        guard let profile = profile, let context = modelContext else { return }

        // Check if we already have this week's quests
        let hasWeekly = profile.quests.contains { $0.questType == .weekly && !$0.isExpired }
        if hasWeekly { return }

        let weeklyQuests = [
            Quest(
                title: "Water 15 plants",
                description: "Keep your garden thriving",
                questType: .weekly,
                category: .watering,
                xpReward: 60,
                target: 15
            ),
            Quest(
                title: "Unlock a rare plant",
                description: "Discover and diagnose a rare species",
                questType: .weekly,
                category: .diagnosis,
                xpReward: 80,
                target: 1
            ),
            Quest(
                title: "Maintain a 7-day streak",
                description: "Daily care without missing a day",
                questType: .weekly,
                category: .streak,
                xpReward: 75,
                target: 7
            )
        ]

        for quest in weeklyQuests {
            context.insert(quest)
            profile.quests.append(quest)
        }

        saveContext()
    }

    func completeQuest(_ quest: Quest, in context: ModelContext) {
        if quest.isCompleted {
            profile?.totalQuestsCompleted += 1
            addXP(quest.xpReward, source: .completingQuest, questId: quest.id)

            showQuestCompletion = (quest, true)
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.showQuestCompletion.show = false
            }

            HapticManager.shared.success()
            saveContext()
        }
    }

    // MARK: - Badges

    func unlockBadge(_ type: BadgeType, in context: ModelContext) {
        guard let profile = profile else { return }

        // Check if already unlocked
        if profile.badges.contains(where: { $0.badgeType == type }) {
            return
        }

        let badge = UnlockedBadge(badgeType: type)
        context.insert(badge)
        profile.badges.append(badge)
        profile.totalBadgesUnlocked += 1

        // Show badge unlock
        showBadgeUnlock = (badge, true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.showBadgeUnlock.show = false
        }

        // Award XP
        addXP(40, source: .badgeUnlock)

        HapticManager.shared.celebration()
        saveContext()
    }

    // MARK: - Streaks

    func updateStreak() {
        guard let profile = profile else { return }

        let oldStreak = profile.dailyStreak
        profile.updateDailyStreak()

        if profile.dailyStreak > oldStreak {
            // Check for streak milestones
            let milestones = [3, 7, 14, 30, 60, 100]
            if milestones.contains(profile.dailyStreak) {
                showStreakFlame = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    self.showStreakFlame = false
                }

                HapticManager.shared.streakFlame()

                if profile.dailyStreak == 7 {
                    unlockBadge(.week, in: modelContext!)
                } else if profile.dailyStreak == 30 {
                    unlockBadge(.month, in: modelContext!)
                } else if profile.dailyStreak == 100 {
                    unlockBadge(.streakOnFire, in: modelContext!)
                }
            }
        }

        saveContext()
    }

    func recordWatering(plantId: UUID) {
        guard let profile = profile, let context = modelContext else { return }

        addXP(10, source: .wateringPlant, plantId: plantId)

        // Update visual progression
        if let progression = profile.plantProgressions.first(where: { $0.plantId == plantId }) {
            progression.updateCareQuality(delta: 5)
        }

        // Check quest progress
        for quest in profile.quests where !quest.isCompleted {
            if quest.category == .watering {
                quest.incrementProgress()
                if quest.isCompleted {
                    completeQuest(quest, in: context)
                }
            }
        }

        HapticManager.shared.wateringSplash()
        saveContext()
    }

    func recordHealthCheck(plantId: UUID) {
        addXP(15, source: .healthCheck, plantId: plantId)

        guard let profile = profile, let context = modelContext else { return }

        // Update quest progress
        for quest in profile.quests where !quest.isCompleted {
            if quest.category == .health {
                quest.incrementProgress()
                if quest.isCompleted {
                    completeQuest(quest, in: context)
                }
            }
        }

        HapticManager.shared.softTap()
        saveContext()
    }

    // MARK: - Visual Progression

    func createVisualProgression(for plantId: UUID) {
        guard let profile = profile, let context = modelContext else { return }

        let progression = VisualProgression(plantId: plantId)
        context.insert(progression)
        profile.plantProgressions.append(progression)
        saveContext()
    }

    func triggerBlooming(for plantId: UUID) {
        guard let progression = profile?.plantProgressions.first(where: { $0.plantId == plantId }) else { return }

        progression.triggerBlooming()
        HapticManager.shared.bloom()
        saveContext()
    }

    // MARK: - Persistence

    private func saveContext() {
        guard let context = modelContext else { return }
        do {
            try context.save()
        } catch {
            #if DEBUG
            print("❌ GamificationManager — Failed to save: \(error)")
            #endif
        }
    }
}
