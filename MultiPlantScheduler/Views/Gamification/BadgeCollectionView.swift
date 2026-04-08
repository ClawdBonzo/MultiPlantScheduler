import SwiftUI

/// Displays unlocked badges and achievements
struct BadgeCollectionView: View {
    @EnvironmentObject var gamificationManager: GamificationManager

    var unlockedBadges: [UnlockedBadge] {
        gamificationManager.profile?.badges ?? []
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text("Badges")
                        .font(.headline)
                        .foregroundColor(.white)

                    Spacer()

                    Text("\(unlockedBadges.count)")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(AppColors.emerald)
                }

                // Badge Grid
                LazyVGrid(
                    columns: [GridItem(.adaptive(minimum: 80), spacing: 12)],
                    spacing: 12
                ) {
                    ForEach(unlockedBadges, id: \.id) { badge in
                        BadgeCardView(badge: badge)
                    }
                }

                if unlockedBadges.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 32))
                            .foregroundColor(.gray)

                        Text("No Badges Yet")
                            .font(.headline)
                            .foregroundColor(.gray)

                        Text("Complete quests and milestones to earn badges")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(32)
                }

                Spacer()
            }
            .padding(16)
        }
    }
}

// MARK: - Badge Card

struct BadgeCardView: View {
    let badge: UnlockedBadge

    var body: some View {
        VStack(spacing: 8) {
            Text(badge.emoji)
                .font(.system(size: 32))

            Text(badge.displayName)
                .font(.caption2)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .lineLimit(2)

            Text(badge.badgeDescription)
                .font(.caption)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity)
        .padding(12)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.black.opacity(0.2),
                    Color.black.opacity(0.4)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(AppColors.emerald.opacity(0.3), lineWidth: 1)
        )
    }
}

// MARK: - Preview

#Preview {
    BadgeCollectionView()
        .environmentObject(GamificationManager.shared)
        .background(Color.black)
}
