import SwiftUI

/// A shareable card image showing the user's plant collection
struct GardenCardView: View {
    let plants: [Plant]
    let maxStreak: Int

    private var displayPlants: [Plant] {
        Array(plants.prefix(6))
    }

    private var overflowCount: Int {
        max(0, plants.count - 6)
    }

    var body: some View {
        VStack(spacing: 20) {
            // Header
            Text("My Garden")
                .font(.title)
                .fontWeight(.bold)
                .foregroundStyle(AppColors.textPrimary)

            // Plant grid
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                ForEach(displayPlants) { plant in
                    VStack(spacing: 6) {
                        if let image = plant.photoImage {
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(width: 80, height: 80)
                                .clipShape(Circle())
                        } else {
                            Circle()
                                .fill(AppColors.forestGreen.opacity(0.3))
                                .frame(width: 80, height: 80)
                                .overlay {
                                    Image(systemName: "leaf.fill")
                                        .font(.system(size: 24, weight: .light))
                                        .foregroundStyle(.white.opacity(0.6))
                                }
                        }
                        Text(plant.name)
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundStyle(AppColors.textPrimary)
                            .lineLimit(1)
                    }
                }
            }

            if overflowCount > 0 {
                Text("+\(overflowCount) more")
                    .font(.subheadline)
                    .foregroundStyle(AppColors.textSecondary)
            }

            // Stats
            HStack(spacing: 30) {
                VStack {
                    Text("\(plants.count)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(AppColors.limeGreen)
                    Text("Plants")
                        .font(.caption)
                        .foregroundStyle(AppColors.textSecondary)
                }
                if maxStreak > 0 {
                    VStack {
                        Text("\(maxStreak)")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundStyle(.orange)
                        Text("Day Streak")
                            .font(.caption)
                            .foregroundStyle(AppColors.textSecondary)
                    }
                }
            }

            // Branding
            HStack(spacing: 4) {
                Text("Made with")
                    .font(.caption2)
                    .foregroundStyle(AppColors.textSecondary.opacity(0.7))
                Text("Multi Plant")
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .foregroundStyle(AppColors.limeGreen.opacity(0.7))
                Image(systemName: "leaf.fill")
                    .font(.caption2)
                    .foregroundStyle(AppColors.limeGreen.opacity(0.7))
            }
        }
        .padding(30)
        .frame(width: 360, height: 480)
        .background(
            LinearGradient(
                colors: [AppColors.background, Color(red: 0.05, green: 0.12, blue: 0.05)],
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 24))
    }
}
