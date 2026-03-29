import SwiftUI

/// Timeline view showing a plant's health check history
struct HealthTimelineView: View {
    let plant: Plant

    private var sortedEntries: [HealthEntry] {
        plant.healthEntries.sorted { $0.date > $1.date }
    }

    private var careCountLast30Days: Int {
        let thirtyDaysAgo = Calendar.current.date(byAdding: .day, value: -30, to: Date.now) ?? Date.now
        return plant.careLogs.filter { $0.logDate >= thirtyDaysAgo }.count
    }

    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 16) {
                    // Summary card
                    HStack(spacing: 20) {
                        VStack {
                            Text("\(careCountLast30Days)")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundStyle(AppColors.limeGreen)
                            Text("Care actions\nlast 30 days")
                                .font(.caption)
                                .foregroundStyle(AppColors.textSecondary)
                                .multilineTextAlignment(.center)
                        }
                        Divider().frame(height: 50)
                        VStack {
                            Text(plant.currentHealth.emoji)
                                .font(.title)
                            Text("Current\nstatus")
                                .font(.caption)
                                .foregroundStyle(AppColors.textSecondary)
                                .multilineTextAlignment(.center)
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.white.opacity(0.05))
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                    // Timeline
                    if sortedEntries.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "heart.text.clipboard")
                                .font(.largeTitle)
                                .foregroundStyle(AppColors.textSecondary)
                            Text("No health checks yet")
                                .foregroundStyle(AppColors.textSecondary)
                        }
                        .padding(.top, 40)
                    } else {
                        ForEach(sortedEntries) { entry in
                            HealthTimelineRow(entry: entry)
                        }
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Health History")
        .navigationBarTitleDisplayMode(.inline)
    }
}

/// A single row in the health timeline
struct HealthTimelineRow: View {
    let entry: HealthEntry

    var body: some View {
        HStack(spacing: 12) {
            // Status dot
            Circle()
                .fill(entry.healthStatus.color)
                .frame(width: 12, height: 12)

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(entry.healthStatus.displayName)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(AppColors.textPrimary)
                    Text(entry.healthStatus.emoji)
                    Spacer()
                    Text(entry.date, style: .date)
                        .font(.caption)
                        .foregroundStyle(AppColors.textSecondary)
                }

                if let notes = entry.notes, !notes.isEmpty {
                    Text(notes)
                        .font(.caption)
                        .foregroundStyle(AppColors.textSecondary)
                }
            }
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}
