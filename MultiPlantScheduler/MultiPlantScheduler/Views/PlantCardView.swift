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
                        AppColors.emerald.opacity(0.5),
                        AppColors.forestGreen.opacity(0.3)
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
                        .font(.system(size: 36, weight: .ultraLight))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [AppColors.limeGreen.opacity(0.6), AppColors.emerald.opacity(0.4)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
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
                            Circle().stroke(AppColors.surface2, lineWidth: 2)
                        )
                        .shadow(color: plant.currentHealth.color.opacity(0.5), radius: 4)
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
                            .font(.system(size: 9, weight: .semibold))

                        Text(room)
                            .font(.system(.caption2, design: .rounded))
                    }
                    .foregroundColor(AppColors.textSecondary.opacity(0.8))
                    .lineLimit(1)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 12)
            .padding(.vertical, 10)

            // Subtle divider
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [Color.clear, Color.white.opacity(0.06), Color.clear],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(height: 0.5)

            // Urgency badge
            HStack {
                HStack(spacing: 4) {
                    Image(systemName: "droplet.fill")
                        .font(.system(size: 11, weight: .semibold))

                    Text(urgencyText)
                        .font(.system(.caption, design: .rounded))
                        .fontWeight(.semibold)
                }
                .foregroundColor(.white)
                .padding(.horizontal, 9)
                .padding(.vertical, 5)
                .background(
                    Capsule().fill(plant.urgencyColor)
                )

                Spacer()
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
        }
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(
                    .ultraThinMaterial
                        .shadow(.inner(color: .white.opacity(0.04), radius: 1, x: 0, y: 1))
                )
                .environment(\.colorScheme, .dark)
        )
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(
                    PremiumGradient.cardStroke(opacity: 0.08),
                    lineWidth: 0.5
                )
        )
        .shadow(color: Color.black.opacity(0.35), radius: 12, x: 0, y: 6)
        .contentShape(RoundedRectangle(cornerRadius: 18))
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
