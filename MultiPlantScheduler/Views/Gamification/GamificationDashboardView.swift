import SwiftUI

/// Main gamification dashboard showing level, streaks, quests, and badges
struct GamificationDashboardView: View {
    @EnvironmentObject var gamificationManager: GamificationManager
    @State private var selectedTab: Int = 0

    var body: some View {
        VStack(spacing: 16) {
            // Header with Level & Streak
            HStack(spacing: 12) {
                // Level Card
                VStack(spacing: 4) {
                    Text(gamificationManager.profile?.levelName ?? "Seedling")
                        .font(.caption2)
                        .foregroundColor(AppColors.emerald)
                        .fontWeight(.semibold)

                    Text("Level \(gamificationManager.profile?.currentLevel ?? 1)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)

                    // XP Progress
                    if let profile = gamificationManager.profile {
                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(Color.black.opacity(0.3))
                                .frame(height: 4)

                            Capsule()
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [AppColors.emerald, AppColors.teal]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: max(CGFloat(profile.xpProgressPercent) / 100 * 80, 2), height: 4)
                        }
                        .frame(width: 80)

                        Text("\(profile.xpProgressPercent)%")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(12)
                .background(Color.black.opacity(0.4))
                .cornerRadius(12)

                // Streak Card
                VStack(spacing: 4) {
                    HStack(spacing: 2) {
                        Image(systemName: "flame.fill")
                            .font(.caption)
                            .foregroundColor(.orange)

                        Text("Streak")
                            .font(.caption2)
                            .foregroundColor(.gray)
                    }

                    Text("\(gamificationManager.profile?.dailyStreak ?? 0)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)

                    Text("days")
                        .font(.caption2)
                        .foregroundColor(.gray)

                    if let multiplier = gamificationManager.profile?.streakMultiplier {
                        if multiplier > 1.0 {
                            Text("×\(String(format: "%.1f", multiplier))")
                                .font(.caption)
                                .foregroundColor(AppColors.emerald)
                                .fontWeight(.semibold)
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(12)
                .background(Color.black.opacity(0.4))
                .cornerRadius(12)
            }

            // Tab Selector
            Picker("Gamification", selection: $selectedTab) {
                Text("Quests").tag(0)
                Text("Badges").tag(1)
                Text("Progress").tag(2)
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, 4)

            // Content based on tab
            TabView(selection: $selectedTab) {
                QuestListView()
                    .tag(0)

                BadgeCollectionView()
                    .tag(1)

                PlantProgressionListView()
                    .tag(2)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(maxHeight: .infinity)
        }
        .padding(16)
        .background(Color.black)
        .onAppear {
            gamificationManager.generateDailyQuests()
            gamificationManager.generateWeeklyQuests()
        }
    }
}

// MARK: - Preview

#Preview {
    GamificationDashboardView()
        .environmentObject(GamificationManager.shared)
}
