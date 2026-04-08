import Foundation
import SwiftUI

/// Central app state manager using @Observable pattern
/// Coordinates overall app state, premium features, and gamification
@Observable
final class AppStateManager {
    static let shared = AppStateManager()

    // MARK: - Onboarding & Lifecycle

    @ObservationIgnored private(set) var hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
    var showOnboarding = false
    var launchAddPlant = false

    // MARK: - Premium & Trial

    var isPremium = false {
        didSet {
            UserDefaults(suiteName: SharedContainer.appGroupID)?
                .set(isPremium, forKey: "isPremium")
        }
    }

    var isTrialActive = false
    var trialRemainingDays: Int = 3
    var selectedPlan: SubscriptionPlan = .basic

    // MARK: - Gamification UI State

    var showLevelUpCelebration = false
    var celebratingLevel: (level: Int, name: String)?

    var showBadgeUnlock = false
    var unlockingBadge: UnlockedBadge?

    var showStreakFlame = false
    var currentStreakDays = 0

    var showXPNotification = false
    var lastXPGain: (amount: Int, source: String)?

    // MARK: - Navigation

    var selectedMainTab: ContentView.Tab = .garden
    var showPaywall = false
    var showSettings = false

    // MARK: - Loading States

    var isLoadingPremiumStatus = false
    var premiumCheckError: Error?

    private init() {
        setupInitialState()
    }

    // MARK: - Setup

    private func setupInitialState() {
        // Load persisted state
        hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
        showOnboarding = !hasCompletedOnboarding

        // Load trial state
        loadTrialState()
    }

    // MARK: - Onboarding Management

    func completeOnboarding() {
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
        hasCompletedOnboarding = true
        showOnboarding = false
        withAnimation {
            launchAddPlant = true
        }
    }

    func resetOnboarding() {
        UserDefaults.standard.set(false, forKey: "hasCompletedOnboarding")
        hasCompletedOnboarding = false
        showOnboarding = true
    }

    // MARK: - Trial Management

    func startTrial() {
        let trialStartDate = Date()
        UserDefaults.standard.set(trialStartDate, forKey: "trialStartDate")
        UserDefaults.standard.set(true, forKey: "isTrialActive")
        isTrialActive = true
        trialRemainingDays = 3
    }

    func loadTrialState() {
        guard let startDate = UserDefaults.standard.object(forKey: "trialStartDate") as? Date else {
            isTrialActive = false
            return
        }

        let daysPassed = Calendar.current.dateComponents([.day], from: startDate, to: Date()).day ?? 0
        let remaining = max(0, 3 - daysPassed)
        isTrialActive = remaining > 0
        trialRemainingDays = remaining
    }

    func endTrial() {
        UserDefaults.standard.removeObject(forKey: "trialStartDate")
        isTrialActive = false
        showPaywall = true
    }

    // MARK: - Premium Management

    func setPremiumStatus(_ isPremium: Bool) {
        self.isPremium = isPremium
        if isPremium {
            isTrialActive = false
        }
    }

    // MARK: - Gamification Celebrations

    func celebrateLevel(level: Int, name: String) {
        celebratingLevel = (level, name)
        withAnimation {
            showLevelUpCelebration = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
            withAnimation {
                self.showLevelUpCelebration = false
            }
        }
    }

    func celebrateBadge(_ badge: UnlockedBadge) {
        unlockingBadge = badge
        withAnimation {
            showBadgeUnlock = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
            withAnimation {
                self.showBadgeUnlock = false
            }
        }
    }

    func celebrateStreak(days: Int) {
        currentStreakDays = days
        withAnimation {
            showStreakFlame = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            withAnimation {
                self.showStreakFlame = false
            }
        }
    }

    func showXPGain(amount: Int, source: String) {
        lastXPGain = (amount, source)
        withAnimation {
            showXPNotification = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation {
                self.showXPNotification = false
            }
        }
    }

    // MARK: - Plan Selection

    enum SubscriptionPlan: String {
        case basic = "basic_monthly"
        case pro = "pro_monthly"
        case max = "max_monthly"
        case premium = "premium_annual"

        var displayName: String {
            switch self {
            case .basic: return "Basic"
            case .pro: return "Pro"
            case .max: return "Max"
            case .premium: return "Premium"
            }
        }

        var monthlyPrice: String {
            switch self {
            case .basic: return "$2.99"
            case .pro: return "$5.99"
            case .max: return "$9.99"
            case .premium: return "$79.99/year"
            }
        }
    }
}
