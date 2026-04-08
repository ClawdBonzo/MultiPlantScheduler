import SwiftUI

/// Shows visual progression of plants (growth stages)
struct PlantProgressionListView: View {
    @EnvironmentObject var gamificationManager: GamificationManager

    var progressions: [VisualProgression] {
        gamificationManager.profile?.plantProgressions ?? []
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Plant Evolution")
                    .font(.headline)
                    .foregroundColor(.white)

                if progressions.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "leaf.fill")
                            .font(.system(size: 32))
                            .foregroundColor(.gray)

                        Text("No Plants Yet")
                            .font(.headline)
                            .foregroundColor(.gray)

                        Text("Add plants to track their growth")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(32)
                } else {
                    VStack(spacing: 12) {
                        ForEach(progressions, id: \.id) { progression in
                            PlantProgressionCardView(progression: progression)
                        }
                    }
                }

                Spacer()
            }
            .padding(16)
        }
    }
}

// MARK: - Progression Card

struct PlantProgressionCardView: View {
    let progression: VisualProgression

    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                // Stage emoji
                Text(progression.stageEmoji)
                    .font(.system(size: 32))

                VStack(alignment: .leading, spacing: 4) {
                    Text("Plant Evolution")
                        .font(.caption)
                        .foregroundColor(.gray)

                    Text(progression.stageName)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)

                    if progression.bloomingActive {
                        HStack(spacing: 4) {
                            Image(systemName: "flower.fill")
                                .font(.caption)
                                .foregroundColor(AppColors.teal)

                            Text("Blooming (\(progression.bloomCount))")
                                .font(.caption)
                                .foregroundColor(AppColors.teal)
                        }
                    }
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text("Care Score")
                        .font(.caption2)
                        .foregroundColor(.gray)

                    Text("\(Int(progression.careQualityScore))")
                        .font(.headline)
                        .foregroundColor(AppColors.emerald)

                    if progression.flourishLevel > 0 {
                        HStack(spacing: 2) {
                            ForEach(0..<progression.flourishLevel, id: \.self) { _ in
                                Image(systemName: "star.fill")
                                    .font(.caption2)
                                    .foregroundColor(AppColors.emerald)
                            }
                        }
                    }
                }
            }

            // Care quality progress
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.white.opacity(0.1))
                    .frame(height: 6)

                Capsule()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [AppColors.emerald, AppColors.teal]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: max(CGFloat(progression.careQualityScore) / 100 * 100, 2), height: 6)
            }

            // Stage progression
            HStack(spacing: 4) {
                ForEach(0..<6, id: \.self) { index in
                    Capsule()
                        .fill(
                            index < GrowthStage.allCases.firstIndex(of: progression.currentStage) ?? 0
                            ? AppColors.emerald
                            : Color.white.opacity(0.1)
                        )
                        .frame(height: 2)
                }
            }
        }
        .padding(12)
        .background(Color.white.opacity(0.05))
        .cornerRadius(10)
    }
}

// MARK: - Helper

extension GrowthStage: CaseIterable {
    public static var allCases: [GrowthStage] {
        [.seedling, .sprout, .growing, .mature, .flourishing, .legendary]
    }
}

// MARK: - Preview

#Preview {
    PlantProgressionListView()
        .environmentObject(GamificationManager.shared)
        .background(Color.black)
}
