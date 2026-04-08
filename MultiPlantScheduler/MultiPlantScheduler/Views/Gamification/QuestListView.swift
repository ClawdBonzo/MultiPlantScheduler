import SwiftUI

/// Displays daily and weekly quests
struct QuestListView: View {
    @EnvironmentObject var gamificationManager: GamificationManager

    var dailyQuests: [Quest] {
        gamificationManager.profile?.quests.filter { !$0.isExpired && $0.questType == .daily } ?? []
    }

    var weeklyQuests: [Quest] {
        gamificationManager.profile?.quests.filter { !$0.isExpired && $0.questType == .weekly } ?? []
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Daily Quests
                VStack(spacing: 12) {
                    HStack {
                        Text("Daily Quests")
                            .font(.headline)
                            .foregroundColor(.white)

                        Spacer()

                        Text("\(dailyQuests.filter(\.isCompleted).count)/\(dailyQuests.count)")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }

                    VStack(spacing: 8) {
                        ForEach(dailyQuests, id: \.id) { quest in
                            QuestRowView(quest: quest)
                        }
                    }
                }

                // Weekly Quests
                if !weeklyQuests.isEmpty {
                    VStack(spacing: 12) {
                        HStack {
                            Text("Weekly Quests")
                                .font(.headline)
                                .foregroundColor(.white)

                            Spacer()

                            Text("\(weeklyQuests.filter(\.isCompleted).count)/\(weeklyQuests.count)")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }

                        VStack(spacing: 8) {
                            ForEach(weeklyQuests, id: \.id) { quest in
                                QuestRowView(quest: quest)
                            }
                        }
                    }
                }

                Spacer()
            }
            .padding(12)
        }
    }
}

// MARK: - Quest Row

struct QuestRowView: View {
    let quest: Quest
    @EnvironmentObject var gamificationManager: GamificationManager

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Text(quest.category.emoji)
                            .font(.body)

                        Text(quest.title)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)

                        Spacer()

                        if quest.isCompleted {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.body)
                                .foregroundColor(AppColors.emerald)
                        }
                    }

                    Text(quest.questDescription)
                        .font(.caption)
                        .foregroundColor(.gray)
                        .lineLimit(1)
                }

                VStack(alignment: .trailing, spacing: 4) {
                    Text("+\(quest.xpReward) XP")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(AppColors.emerald)

                    Text(quest.progressDisplay)
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
            }

            // Progress bar
            if !quest.isCompleted {
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.white.opacity(0.1))
                        .frame(height: 4)

                    Capsule()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [AppColors.emerald, AppColors.teal]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: max(CGFloat(quest.progressPercent) * 100, 2), height: 4)
                }
            }
        }
        .padding(12)
        .background(Color.white.opacity(0.05))
        .cornerRadius(10)
        .overlay(
            quest.isCompleted ?
            RoundedRectangle(cornerRadius: 10)
                .stroke(AppColors.emerald.opacity(0.3), lineWidth: 1) :
            nil
        )
    }
}

// MARK: - Preview

#Preview {
    QuestListView()
        .environmentObject(GamificationManager.shared)
        .background(Color.black)
}
