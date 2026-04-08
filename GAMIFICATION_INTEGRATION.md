# Gamification System Integration Guide

## Overview
Complete Duolingo-style gamification layer with XP, levels, quests, badges, and haptic feedback.

## Architecture

### Models (SwiftData)
- **GamificationProfile**: User's XP, level, streaks, quest/badge collections
- **Quest**: Daily/weekly quests with progress tracking
- **UnlockedBadge**: Earned badges with unlock dates
- **VisualProgression**: Plant growth stages and care quality
- **XPHistory**: XP gain tracking for analytics

### Services
- **GamificationManager**: Central orchestrator (ObservableObject)
  - Manages XP, leveling, quests, badges, streaks
  - Triggers celebrations and haptics
- **HapticManager**: Haptic feedback patterns
  - Feedback for watering, quests, badges, streaks, level-ups

### Views
- **GamificationDashboardView**: Main hub with level, streaks, quests, badges
- **QuestListView**: Daily/weekly quest tracking
- **BadgeCollectionView**: Badge showcase
- **PlantProgressionListView**: Plant growth visualization
- **LevelUpCelebrationView**: Level-up celebration animation
- **BadgeUnlockView**: Badge unlock celebration
- **StreakFlameView**: Streak milestone celebration

## Integration Steps

### 1. Initialize in App
In `MultiPlantSchedulerApp.swift`:

```swift
@main
struct MultiPlantSchedulerApp: App {
    @StateObject private var gamificationManager = GamificationManager.shared
    let modelContext: ModelContext

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(gamificationManager)
                .onAppear {
                    gamificationManager.initialize(with: modelContext)
                }
        }
        .modelContainer(for: [Plant.self, CareLog.self, GamificationProfile.self, Quest.self, UnlockedBadge.self, VisualProgression.self, XPHistory.self], inMemory: false)
    }
}
```

### 2. Add to Dashboard/Main Views
In `DashboardView.swift` or main content area:

```swift
// Add tab for gamification
TabView(selection: $selectedTab) {
    DashboardView()
        .tag("dashboard")
    
    GamificationDashboardView()
        .tag("gamification")
    
    // ... other tabs
}
```

### 3. Hook into Plant Care Actions
In `WateringService.swift` or where water actions are recorded:

```swift
func waterPlant(_ plant: Plant) {
    // ... existing watering logic
    
    // Track for gamification
    GamificationManager.shared.recordWatering(plantId: plant.id)
    GamificationManager.shared.updateStreak()
    
    // Create visual progression if needed
    if GamificationManager.shared.profile?.plantProgressions.first(where: { $0.plantId == plant.id }) == nil {
        GamificationManager.shared.createVisualProgression(for: plant.id)
    }
}
```

### 4. Hook Health Checks
After health check completion:

```swift
GamificationManager.shared.recordHealthCheck(plantId: plant.id)
```

### 5. Show Celebrations Overlay
In main view hierarchy:

```swift
ZStack {
    // Main content
    ContentView()
        .environmentObject(gamificationManager)
    
    // Celebration overlays
    if gamificationManager.showLevelUpCelebration,
       let level = gamificationManager.profile?.currentLevel,
       let levelName = gamificationManager.profile?.levelName {
        LevelUpCelebrationView(level: level, levelName: levelName)
            .transition(.opacity)
    }
    
    if gamificationManager.showBadgeUnlock.show {
        BadgeUnlockView(badge: gamificationManager.showBadgeUnlock.badge)
            .transition(.opacity)
    }
    
    if gamificationManager.showStreakFlame {
        StreakFlameView(
            currentStreak: gamificationManager.profile?.dailyStreak ?? 0,
            multiplier: gamificationManager.profile?.streakMultiplier ?? 1.0
        )
        .transition(.opacity)
    }
}
```

## Key Features

### XP System
- Base XP rewards per action:
  - Water plant: 10 XP
  - Health check: 15 XP
  - Diagnosis: 20 XP
  - Complete quest: 25 XP
  - Streak milestone: 50 XP
  - Badge unlock: 40 XP
- Streak multiplier (1.0x → 2.0x) scales XP rewards
- XP history tracked in SwiftData

### Levels (1-10+)
- Seedling → Sprout → Young Plant → Growing Gardener → Plant Parent
- Master Gardener → Botanical Expert → Plant Whisperer → Greenhouse Master → Legendary Cultivator
- Exponential XP requirements (100 * level)

### Quests
- **Daily**: Water 3 plants, Perfect care day, Check health 2 plants
- **Weekly**: Water 15 plants, Unlock rare plant, Maintain 7-day streak
- Auto-expire after 1 day (daily) or 7 days (weekly)
- Progress-tracked with visual bars

### Badges (20+ types)
- **Watering**: First Water, Water Master, Water 10/50/100 plants
- **Streaks**: Week, Month, Perfect Care, Unstoppable (100+ days)
- **Health**: Health Inspector, Champion, Diagnosis Expert, Rare Plant Expert
- **Collection**: Plant Parent, 5/10/20 plants, Botanist
- **Milestones**: Level Up, Master Gardener, Community Star, Viral Sensation

### Plant Visual Progression
- **Growth Stages**: Seedling → Sprout → Growing → Mature → Flourishing → Legendary
- **Care Quality Score** (0-100) affects appearance
- **Flourish Levels** (0-3) with star indicators
- **Blooming** state with bloom count tracking

### Haptics
- **Soft tap**: Quest progress, interactions
- **Success**: Quest/goal completion
- **Celebration**: Level-up, badge unlock (3 strong pulses)
- **Streak flame**: Escalating pulses for milestone streaks
- **Watering splash**: Two-tap splash effect
- **Bloom**: Delicate flourishing pattern
- **Warning**: Streak breaking
- Fallback to UIImpactFeedback if CoreHaptics unavailable

## Customization

### Adjust XP Rewards
In `XPSource` enum in `XPHistory.swift`:

```swift
case .wateringPlant: return 10  // Change from 10
```

### Add New Quest Types
In `Quest.swift`:

```swift
Quest(
    title: "Custom Quest",
    description: "Do something special",
    questType: .daily,
    category: .watering,  // or create new category
    xpReward: 30,
    target: 5
)
```

### Add New Badges
In `BadgeType` enum in `UnlockedBadge.swift`:

```swift
case customAchievement

var displayName: String {
    switch self {
    case .customAchievement: return "My Badge"
    // ...
    }
}
```

### Adjust Haptics
In `HapticManager.swift`, modify pattern definitions in the `pattern()` method:

```swift
CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.8)  // 0-1
CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.5)  // 0-1
```

## Testing
- All models persist in SwiftData
- GamificationManager accessible via EnvironmentObject
- Celebration views auto-dismiss after 2-3 seconds
- Haptics fallback safely if unavailable
- Preview providers included in all views

## Files Created
- Models/Gamification/*.swift (5 files)
- Services/GamificationManager.swift
- Services/HapticManager.swift
- Views/Gamification/*.swift (6 files)

Total: 12 new files, ~1500 lines of code
