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
                .font(.system(.title, design: .rounded))
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
                                .overlay(
                                    Circle().stroke(AppColors.emerald.opacity(0.3), lineWidth: 1.5)
                                )
                        } else {
                            Circle()
                                .fill(AppColors.emerald.opacity(0.15))
                                .frame(width: 80, height: 80)
                                .overlay {
                                    Image(systemName: "leaf.fill")
                                        .font(.system(size: 24, weight: .light))
                                        .foregroundStyle(AppColors.emerald.opacity(0.5))
                                }
                        }
                        Text(plant.name)
                            .font(.system(.caption, design: .rounded))
                            .fontWeight(.medium)
                            .foregroundStyle(AppColors.textPrimary)
                            .lineLimit(1)
                    }
                }
            }

            if overflowCount > 0 {
                Text(String(format: NSLocalizedString("+%d more", comment: "Overflow plant count"), overflowCount))
                    .font(.system(.subheadline, design: .rounded))
                    .foregroundStyle(AppColors.textSecondary)
            }

            // Stats
            HStack(spacing: 30) {
                VStack {
                    Text("\(plants.count)")
                        .font(.system(.title2, design: .rounded))
                        .fontWeight(.bold)
                        .foregroundStyle(AppColors.emerald)
                    Text("Plants")
                        .font(.system(.caption, design: .rounded))
                        .foregroundStyle(AppColors.textSecondary)
                }
                if maxStreak > 0 {
                    VStack {
                        Text("\(maxStreak)")
                            .font(.system(.title2, design: .rounded))
                            .fontWeight(.bold)
                            .foregroundStyle(.orange)
                        Text("Day Streak")
                            .font(.system(.caption, design: .rounded))
                            .foregroundStyle(AppColors.textSecondary)
                    }
                }
            }

            // Branding
            HStack(spacing: 4) {
                Text("Made with")
                    .font(.system(.caption2, design: .rounded))
                    .foregroundStyle(AppColors.textSecondary.opacity(0.7))
                Text("MultiPlant AI")
                    .font(.system(.caption2, design: .rounded))
                    .fontWeight(.semibold)
                    .foregroundStyle(AppColors.emerald.opacity(0.8))
                Image(systemName: "leaf.fill")
                    .font(.caption2)
                    .foregroundStyle(AppColors.emerald.opacity(0.8))
            }
        }
        .padding(30)
        .frame(width: 360, height: 480)
        .background(
            ZStack {
                LinearGradient(
                    colors: [AppColors.background, AppColors.deepForest],
                    startPoint: .top,
                    endPoint: .bottom
                )
                // Subtle ambient glow
                RadialGradient(
                    colors: [AppColors.emerald.opacity(0.06), .clear],
                    center: .center,
                    startRadius: 20,
                    endRadius: 200
                )
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(PremiumGradient.cardStroke(opacity: 0.12), lineWidth: 0.5)
        )
    }
}
