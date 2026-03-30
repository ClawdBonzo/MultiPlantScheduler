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
                Image(systemName: "checklist")
                    .foregroundStyle(AppColors.limeGreen)
                Text("Today's Watering")
                    .font(.headline)
                    .foregroundStyle(AppColors.textPrimary)
                Spacer()
                Text("\(duePlants.count)")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(duePlants.isEmpty ? AppColors.forestGreen : Color.red)
                    .clipShape(Capsule())
                    .foregroundStyle(.white)
            }

            if duePlants.isEmpty {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(AppColors.limeGreen)
                        .font(.title2)
                    Text("All caught up! No plants need water today.")
                        .font(.subheadline)
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
        .padding()
        .background(Color.white.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func waterPlant(_ plant: Plant) {
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()

        _ = withAnimation(.easeInOut(duration: 0.4)) {
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
            } else {
                Circle()
                    .fill(AppColors.forestGreen.opacity(0.3))
                    .frame(width: 40, height: 40)
                    .overlay {
                        Image(systemName: "leaf.fill")
                            .font(.system(size: 14, weight: .light))
                            .foregroundStyle(.white.opacity(0.6))
                    }
            }

            // Plant info
            VStack(alignment: .leading, spacing: 2) {
                Text(plant.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(AppColors.textPrimary)

                Text(plant.isOverdue
                    ? String(format: NSLocalizedString("Overdue by %dd", comment: "Overdue days"), abs(plant.daysUntilWatering))
                    : NSLocalizedString("Due today", comment: "Due today"))
                    .font(.caption)
                    .foregroundStyle(plant.isOverdue ? Color.red : Color.yellow)
            }

            Spacer()

            // Water button
            Button(action: onWater) {
                Image(systemName: showCheck ? "checkmark.circle.fill" : "drop.circle.fill")
                    .font(.title2)
                    .foregroundStyle(showCheck ? AppColors.limeGreen : .blue)
                    .symbolEffect(.bounce, value: showCheck)
            }
        }
        .padding(.vertical, 4)
    }
}
