import SwiftUI
import SwiftData

/// Checklist of plants that need watering today or are overdue
struct TodayChecklistView: View {
    let plants: [Plant]
    @Environment(\.modelContext) var modelContext
    @State private var wateredPlantIDs: Set<UUID> = []

    private var duePlants: [Plant] {
        plants.filter { ($0.isDueToday || $0.isOverdue) && !wateredPlantIDs.contains($0.id) }
            .sorted { ($0.daysUntilWatering) < ($1.daysUntilWatering) }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "checklist")
                        .foregroundStyle(
                            LinearGradient(
                                colors: [AppColors.emerald, AppColors.limeGreen],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                    Text("Today's Watering")
                        .font(.system(.headline, design: .rounded))
                        .fontWeight(.bold)
                        .foregroundStyle(AppColors.textPrimary)
                }

                Spacer()

                Text("\(duePlants.count)")
                    .font(.system(.caption2, design: .rounded))
                    .fontWeight(.bold)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        Capsule().fill(duePlants.isEmpty ? AppColors.emerald : AppColors.urgencyCritical)
                    )
                    .foregroundStyle(.white)
            }

            if duePlants.isEmpty {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(AppColors.emerald)
                        .font(.title2)
                    Text("All caught up! No plants need water today.")
                        .font(.system(.subheadline, design: .rounded))
                        .foregroundStyle(AppColors.textSecondary)
                }
                .padding(.vertical, 8)
            } else {
                ForEach(duePlants) { plant in
                    TodayPlantRow(plant: plant) {
                        waterPlant(plant)
                    }
                    .transition(.asymmetric(
                        insertion: .identity,
                        removal: .move(edge: .trailing).combined(with: .opacity)
                    ))
                }
            }
        }
        .premiumGlass(cornerRadius: 18, strokeOpacity: 0.08, padding: 16)
    }

    private func waterPlant(_ plant: Plant) {
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()

        _ = withAnimation(SpringPreset.smooth) {
            wateredPlantIDs.insert(plant.id)
        }

        WateringService.markAsWatered(plant: plant, context: modelContext)
    }
}

/// A single row in the today checklist
struct TodayPlantRow: View {
    let plant: Plant
    let onWater: () -> Void
    @State private var showCheck = false

    var body: some View {
        HStack(spacing: 12) {
            // Plant thumbnail
            if let image = plant.photoImage {
                image
                    .resizable()
                    .scaledToFill()
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
                    .overlay(
                        Circle().stroke(Color.white.opacity(0.08), lineWidth: 0.5)
                    )
            } else {
                Circle()
                    .fill(AppColors.emerald.opacity(0.15))
                    .frame(width: 40, height: 40)
                    .overlay {
                        Image(systemName: "leaf.fill")
                            .font(.system(size: 14, weight: .light))
                            .foregroundStyle(AppColors.emerald.opacity(0.6))
                    }
            }

            // Plant info
            VStack(alignment: .leading, spacing: 2) {
                Text(plant.name)
                    .font(.system(.subheadline, design: .rounded))
                    .fontWeight(.medium)
                    .foregroundStyle(AppColors.textPrimary)

                Text(plant.isOverdue
                    ? String(format: NSLocalizedString("Overdue by %dd", comment: "Overdue days"), abs(plant.daysUntilWatering))
                    : NSLocalizedString("Due today", comment: "Due today"))
                    .font(.system(.caption, design: .rounded))
                    .foregroundStyle(plant.isOverdue ? AppColors.urgencyCritical : AppColors.urgencyWarning)
            }

            Spacer()

            // Water button
            Button(action: onWater) {
                Image(systemName: showCheck ? "checkmark.circle.fill" : "drop.circle.fill")
                    .font(.title2)
                    .foregroundStyle(showCheck ? AppColors.emerald : .blue)
                    .symbolEffect(.bounce, value: showCheck)
            }
        }
        .padding(.vertical, 4)
    }
}
