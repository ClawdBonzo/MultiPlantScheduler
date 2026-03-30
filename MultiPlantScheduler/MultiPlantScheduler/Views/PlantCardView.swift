import SwiftUI

struct PlantCardView: View {
    let plant: Plant

    @State private var isPressed = false

    var urgencyText: String {
        if plant.isOverdue {
            let days = abs(plant.daysUntilWatering)
            return String(format: NSLocalizedString("Overdue %dd", comment: "Overdue days short"), days)
        } else if plant.isDueToday {
            return NSLocalizedString("Due today", comment: "Due today")
        } else {
            return String(format: NSLocalizedString("Water in %dd", comment: "Water in days short"), plant.daysUntilWatering)
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Photo area
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [
                        AppColors.forestGreen.opacity(0.6),
                        AppColors.limeGreen.opacity(0.4)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )

                if let photoImage = plant.photoImage {
                    photoImage
                        .resizable()
                        .scaledToFill()
                        .clipped()
                } else {
                    Image(systemName: "leaf.fill")
                        .font(.system(size: 36, weight: .light))
                        .foregroundStyle(.white.opacity(0.6))
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .frame(height: 120)
            .clipped()
            .overlay(alignment: .topTrailing) {
                if plant.currentHealth != .unknown {
                    Circle()
                        .fill(plant.currentHealth.color)
                        .frame(width: 12, height: 12)
                        .overlay(
                            Circle().stroke(Color(red: 0.118, green: 0.118, blue: 0.118), lineWidth: 2)
                        )
                        .padding(8)
                }
            }

            // Info section
            VStack(alignment: .leading, spacing: 6) {
                Text(plant.name)
                    .font(.system(.headline, design: .rounded))
                    .fontWeight(.semibold)
                    .foregroundColor(AppColors.textPrimary)
                    .lineLimit(2)

                if let species = plant.species, !species.isEmpty {
                    Text(species)
                        .font(.system(.caption, design: .rounded))
                        .foregroundColor(AppColors.textSecondary)
                        .lineLimit(1)
                }

                if let room = plant.room, !room.isEmpty {
                    HStack(spacing: 4) {
                        Image(systemName: "location.fill")
                            .font(.system(size: 10, weight: .semibold))

                        Text(room)
                            .font(.system(.caption2, design: .rounded))
                    }
                    .foregroundColor(AppColors.textSecondary)
                    .lineLimit(1)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 12)
            .padding(.vertical, 10)

            Divider()
                .background(AppColors.textSecondary.opacity(0.2))

            // Urgency badge
            HStack {
                HStack(spacing: 4) {
                    Image(systemName: "droplet.fill")
                        .font(.system(size: 12, weight: .semibold))

                    Text(urgencyText)
                        .font(.system(.caption, design: .rounded))
                        .fontWeight(.semibold)
                }
                .foregroundColor(.white)
                .padding(.horizontal, 8)
                .padding(.vertical, 6)
                .background(plant.urgencyColor)
                .cornerRadius(6)

                Spacer()
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
        }
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(red: 0.118, green: 0.118, blue: 0.118)) // #1E1E1E
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .contentShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color.black.opacity(0.3), radius: 8, x: 0, y: 4)
    }
}

#Preview {
    let plant = Plant(
        name: "Monstera Deliciosa",
        species: "Monstera deliciosa",
        wateringIntervalDays: 7,
        room: "Living Room",
        notes: "Loves humidity"
    )

    PlantCardView(plant: plant)
        .padding(20)
        .background(AppColors.background)
}
