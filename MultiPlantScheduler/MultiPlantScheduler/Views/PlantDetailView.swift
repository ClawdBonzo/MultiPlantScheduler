import SwiftUI
import SwiftData

struct PlantDetailView: View {
    @Bindable var plant: Plant
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var revenueCatManager: RevenueCatManager

    @State private var showEditSheet = false
    @State private var showDeleteConfirmation = false
    @State private var showPaywall = false
    @State private var showCheckmark = false

    var adjustedWateringInterval: Int {
        SeasonalAdjuster.adjustedInterval(baseInterval: plant.wateringIntervalDays)
    }

    var sortedCareLogs: [CareLog] {
        plant.careLogs.sorted { $0.logDate > $1.logDate }
    }

    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 0) {
                    // Hero section
                    ZStack {
                        LinearGradient(
                            gradient: Gradient(colors: [
                                AppColors.forestGreen.opacity(0.8),
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
                                    .font(.system(size: 80))
                            }
                        }
                    }
                    .frame(height: 250)
                    .clipped()

                    VStack(spacing: 24) {
                        // Info section
                        VStack(alignment: .leading, spacing: 12) {
                            Text(plant.name)
                                .font(.system(.title, design: .rounded))
                                .fontWeight(.bold)
                                .foregroundColor(AppColors.textPrimary)

                            VStack(alignment: .leading, spacing: 10) {
                                if let species = plant.species {
                                    InfoRow(label: "Species", value: species)
                                }

                                if let room = plant.room {
                                    InfoRow(label: "Location", value: room)
                                }

                                InfoRow(
                                    label: "Watering",
                                    value: "\(plant.wateringIntervalDays)d\(adjustedWateringInterval != plant.wateringIntervalDays ? " → \(adjustedWateringInterval)d (seasonal)" : "")"
                                )

                                if let fertilizerType = plant.fertilizerType, !fertilizerType.isEmpty {
                                    InfoRow(label: "Fertilizer", value: fertilizerType)
                                }

                                if let notes = plant.notes, !notes.isEmpty {
                                    InfoRow(label: "Notes", value: notes)
                                }

                                if let createdDate = plant.createdAt.formatted(date: .abbreviated, time: .omitted) as String? {
                                    InfoRow(label: "Added", value: plant.createdAt.formatted(date: .abbreviated, time: .omitted))
                                }
                            }
                        }
                        .padding(.horizontal, 20)

                        // Quick action buttons
                        VStack(spacing: 12) {
                            Text("Quick Care")
                                .font(.system(.headline, design: .rounded))
                                .fontWeight(.semibold)
                                .foregroundColor(AppColors.textPrimary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, 20)

                            HStack(spacing: 10) {
                                ForEach([CareType.water, CareType.fertilize, CareType.mist, CareType.repot], id: \.rawValue) { careType in
                                    Button(action: {
                                        performCareAction(careType)
                                    }) {
                                        VStack(spacing: 6) {
                                            Image(systemName: careType.iconName)
                                                .font(.system(size: 18, weight: .semibold))

                                            Text(careType.label)
                                                .font(.system(.caption2, design: .rounded))
                                                .fontWeight(.semibold)
                                                .lineLimit(1)
                                        }
                                        .frame(maxWidth: .infinity)
                                        .foregroundColor(.white)
                                        .padding(.vertical, 12)
                                        .background(careType.color)
                                        .cornerRadius(10)
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                        }

                        // Stats section
                        VStack(spacing: 12) {
                            HStack(spacing: 16) {
                                StatCard(label: "Streak", value: "\(plant.wateringStreak)", icon: "🔥")
                                StatCard(label: "Care Logs", value: "\(plant.careLogs.count)", icon: "📋")
                            }
                        }
                        .padding(.horizontal, 20)

                        // Care history
                        if !sortedCareLogs.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Care History")
                                    .font(.system(.headline, design: .rounded))
                                    .fontWeight(.semibold)
                                    .foregroundColor(AppColors.textPrimary)

                                VStack(spacing: 8) {
                                    ForEach(sortedCareLogs.prefix(10)) { log in
                                        CareLogRow(log: log)
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                        }

                        // Export button
                        if revenueCatManager.isPremium {
                            ShareLink(
                                item: generateCSV(),
                                subject: Text("Care History for \(plant.name)"),
                                message: Text("Exporting plant care data"),
                                preview: SharePreview("Care History")
                            ) {
                                HStack(spacing: 8) {
                                    Image(systemName: "square.and.arrow.up")
                                        .font(.system(size: 14, weight: .semibold))

                                    Text("Export Care History")
                                        .font(.system(.body, design: .rounded))
                                        .fontWeight(.semibold)
                                }
                                .frame(maxWidth: .infinity)
                                .foregroundColor(AppColors.background)
                                .padding(.vertical, 12)
                                .background(AppColors.limeGreen)
                                .cornerRadius(10)
                            }
                            .padding(.horizontal, 20)
                        }

                        Spacer(minLength: 20)
                    }
                    .padding(.vertical, 24)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button(action: { showEditSheet = true }) {
                        Label("Edit", systemImage: "pencil")
                    }

                    Button(action: { showDeleteConfirmation = true }) {
                        Label("Delete", systemImage: "trash")
                            .foregroundColor(.red)
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(AppColors.limeGreen)
                }
            }
        }
        .sheet(isPresented: $showEditSheet) {
            AddPlantView(plantToEdit: plant)
                .presentationDetents([.large])
        }
        .alert("Delete Plant", isPresented: $showDeleteConfirmation) {
            Button("Cancel", role: .cancel) { }

            Button("Delete", role: .destructive) {
                deletePlant()
            }
        } message: {
            Text("Are you sure you want to delete \(plant.name)? This cannot be undone.")
        }
        .sheet(isPresented: $showPaywall) {
            PaywallView()
                .presentationDetents([.medium, .large])
        }
    }

    private func performCareAction(_ careType: CareType) {
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()

        let careLog = CareLog(
            careType: careType.rawValue,
            plant: plant
        )

        plant.careLogs.append(careLog)

        if careType == .water {
            // Check streak before updating lastWateredDate
            let wasOnTime = !plant.isOverdue
            plant.lastWateredDate = Date.now

            if wasOnTime {
                plant.wateringStreak += 1
            } else {
                plant.wateringStreak = 1
            }
        } else if careType == .fertilize {
            plant.lastFertilizedDate = Date.now
        }

        try? modelContext.save()

        Task {
            await NotificationManager.shared.rescheduleAllReminders(plants: [plant])
        }

        withAnimation {
            showCheckmark = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            withAnimation {
                showCheckmark = false
            }
        }
    }

    private func deletePlant() {
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()

        modelContext.delete(plant)
        try? modelContext.save()

        Task {
            await NotificationManager.shared.cancelReminder(for: plant)
        }

        dismiss()
    }

    private func generateCSV() -> URL {
        var csvContent = "Date,Care Type,Notes\n"

        for log in sortedCareLogs {
            let dateString = log.logDate.formatted(date: .abbreviated, time: .shortened)
            let notes = log.notes?.replacingOccurrences(of: "\"", with: "\"\"") ?? ""
            csvContent += "\"\(dateString)\",\(log.careType),\"\(notes)\"\n"
        }

        let fileName = "CareLogs_\(plant.name)_\(Date.now.formatted(date: .abbreviated, time: .omitted)).csv"
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)

        try? csvContent.write(to: url, atomically: true, encoding: .utf8)

        return url
    }
}

struct InfoRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .font(.system(.body, design: .rounded))
                .fontWeight(.semibold)
                .foregroundColor(AppColors.textSecondary)

            Spacer()

            Text(value)
                .font(.system(.body, design: .rounded))
                .fontWeight(.medium)
                .foregroundColor(AppColors.textPrimary)
                .multilineTextAlignment(.trailing)
        }
        .padding(.vertical, 8)
    }
}

struct StatCard: View {
    let label: String
    let value: String
    let icon: String

    var body: some View {
        VStack(spacing: 8) {
            Text(icon)
                .font(.system(size: 28))

            VStack(spacing: 2) {
                Text(value)
                    .font(.system(.title3, design: .rounded))
                    .fontWeight(.bold)
                    .foregroundColor(AppColors.limeGreen)

                Text(label)
                    .font(.system(.caption, design: .rounded))
                    .foregroundColor(AppColors.textSecondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(16)
        .background(Color(red: 0.118, green: 0.118, blue: 0.118))
        .cornerRadius(12)
    }
}

struct CareLogRow: View {
    let log: CareLog

    var careType: CareType? {
        CareType(rawValue: log.careType)
    }

    var body: some View {
        HStack(spacing: 12) {
            if let careType = careType {
                Image(systemName: careType.iconName)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(careType.color)
                    .frame(width: 32, height: 32)
                    .background(careType.color.opacity(0.2))
                    .cornerRadius(8)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(log.careType)
                    .font(.system(.body, design: .rounded))
                    .fontWeight(.semibold)
                    .foregroundColor(AppColors.textPrimary)

                Text(log.logDate.formatted(date: .abbreviated, time: .shortened))
                    .font(.system(.caption, design: .rounded))
                    .foregroundColor(AppColors.textSecondary)

                if let notes = log.notes, !notes.isEmpty {
                    Text(notes)
                        .font(.system(.caption, design: .rounded))
                        .foregroundColor(AppColors.textSecondary)
                        .lineLimit(1)
                }
            }

            Spacer()
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 12)
        .background(Color(red: 0.118, green: 0.118, blue: 0.118))
        .cornerRadius(10)
    }
}

#Preview {
    let plant = Plant(
        name: "Monstera Deliciosa",
        species: "Monstera deliciosa",
        wateringIntervalDays: 7,
        room: "Living Room",
        notes: "Loves humidity",
        fertilizerType: "Balanced NPK"
    )

    NavigationStack {
        PlantDetailView(plant: plant)
            .environmentObject(RevenueCatManager.shared)
    }
}
