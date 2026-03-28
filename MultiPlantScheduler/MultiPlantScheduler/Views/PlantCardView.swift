import SwiftUI

struct PlantCardView: View {
    let plant: Plant

    @State private var isPressed = false

    var urgencyText: String {
        if plant.isOverdue {
            let days = abs(plant.daysUntilWatering)
            return "Overdue \(days)d"
        } else if plant.isDueToday {
            return "Due today"
        } else {
            return "Water in \(plant.daysUntilWatering)d"
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
                    VStack {
                        Text("🌿")
                            .font(.system(size: 44))
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .frame(height: 120)
            .clipped()

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
        .shadow(color: Color.black.opacity(0.3), radius: 8, x: 0, y: 4)
        .scaleEffect(isPressed ? 0.97 : 1.0)
        .onLongPressGesture(
            minimumDuration: 0.1,
            perform: {},
            onPressingChanged: { isPressed = $0 }
        )
        .animation(.easeInOut(duration: 0.15), value: isPressed)
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
