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
    @State private var showHealthCheck = false
    @State private var isReidentifying = false
    @State private var reidentifyResult: String?

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
                            Image(systemName: "leaf.fill")
                                .font(.system(size: 56, weight: .light))
                                .foregroundStyle(.white.opacity(0.5))
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

                                // Health status
                                HStack {
                                    Text("Health")
                                        .font(.system(.body, design: .rounded))
                                        .fontWeight(.semibold)
                                        .foregroundColor(AppColors.textSecondary)
                                    Spacer()
                                    HStack(spacing: 6) {
                                        Circle()
                                            .fill(plant.currentHealth.color)
                                            .frame(width: 10, height: 10)
                                        Text(plant.currentHealth.displayName)
                                            .font(.system(.body, design: .rounded))
                                            .fontWeight(.medium)
                                            .foregroundColor(AppColors.textPrimary)
                                    }
                                }
                                .padding(.vertical, 8)
                            }

                            // AI confidence badge
                            if let confidence = plant.aiConfidence {
                                HStack(spacing: 6) {
                                    Image(systemName: "brain")
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundStyle(AppColors.limeGreen)
                                    Text("AI Identified: \(Int(confidence * 100))% confidence")
                                        .font(.system(.caption, design: .rounded))
                                        .fontWeight(.medium)
                                        .foregroundColor(AppColors.textSecondary)
                                    if let date = plant.lastIdentifiedDate {
                                        Spacer()
                                        Text(date.formatted(date: .abbreviated, time: .omitted))
                                            .font(.system(.caption2, design: .rounded))
                                            .foregroundColor(AppColors.textSecondary.opacity(0.7))
                                    }
                                }
                                .padding(.vertical, 4)
                            }

                            // Re-identify with AI
                            if plant.photoData != nil {
                                Button {
                                    reidentifyPlant()
                                } label: {
                                    HStack(spacing: 8) {
                                        if isReidentifying {
                                            ProgressView()
                                                .tint(AppColors.limeGreen)
                                                .scaleEffect(0.8)
                                        } else {
                                            Image(systemName: "brain")
                                                .foregroundStyle(AppColors.limeGreen)
                                        }
                                        Text(isReidentifying ? "Identifying…" : "Re-identify with AI")
                                            .font(.caption)
                                            .foregroundStyle(AppColors.textSecondary)
                                        Spacer()
                                        if let result = reidentifyResult {
                                            Text(result)
                                                .font(.caption2)
                                                .fontWeight(.medium)
                                                .foregroundStyle(AppColors.limeGreen)
                                        } else {
                                            Image(systemName: "chevron.right")
                                                .font(.caption)
                                                .foregroundStyle(AppColors.textSecondary)
                                        }
                                    }
                                    .padding(10)
                                    .background(AppColors.limeGreen.opacity(0.1))
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                }
                                .disabled(isReidentifying)
                            }

                            // Health check prompt
                            if plant.isHealthCheckDue {
                                Button {
                                    showHealthCheck = true
                                } label: {
                                    HStack(spacing: 8) {
                                        Image(systemName: "heart.text.clipboard")
                                            .foregroundStyle(AppColors.limeGreen)
                                        Text("Time for a health check!")
                                            .font(.caption)
                                            .foregroundStyle(AppColors.textSecondary)
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                            .font(.caption)
                                            .foregroundStyle(AppColors.textSecondary)
                                    }
                                    .padding(10)
                                    .background(AppColors.limeGreen.opacity(0.1))
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
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
                                // Health check button
                                Button(action: { showHealthCheck = true }) {
                                    VStack(spacing: 6) {
                                        Image(systemName: "heart.fill")
                                            .font(.system(size: 18, weight: .semibold))

                                        Text("Health")
                                            .font(.system(.caption2, design: .rounded))
                                            .fontWeight(.semibold)
                                            .lineLimit(1)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .foregroundColor(.white)
                                    .padding(.vertical, 12)
                                    .background(Color.pink)
                                    .cornerRadius(10)
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

                        // Feature links
                        VStack(spacing: 10) {
                            NavigationLink {
                                HealthTimelineView(plant: plant)
                            } label: {
                                HStack {
                                    Image(systemName: "heart.text.clipboard")
                                        .foregroundStyle(.pink)
                                    Text("Health History")
                                        .foregroundStyle(AppColors.textPrimary)
                                    Spacer()
                                    Text("\(plant.healthEntries.count)")
                                        .foregroundStyle(AppColors.textSecondary)
                                    Image(systemName: "chevron.right")
                                        .foregroundStyle(AppColors.textSecondary)
                                }
                                .padding()
                                .background(Color(red: 0.118, green: 0.118, blue: 0.118))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            }

                            if revenueCatManager.isPremium {
                                NavigationLink {
                                    PhotoTimelineView(plant: plant)
                                } label: {
                                    HStack {
                                        Image(systemName: "photo.on.rectangle.angled")
                                            .foregroundStyle(AppColors.limeGreen)
                                        Text("Photo Timeline")
                                            .foregroundStyle(AppColors.textPrimary)
                                        Spacer()
                                        Text("\(plant.photoEntries.count)")
                                            .foregroundStyle(AppColors.textSecondary)
                                        Image(systemName: "chevron.right")
                                            .foregroundStyle(AppColors.textSecondary)
                                    }
                                    .padding()
                                    .background(Color(red: 0.118, green: 0.118, blue: 0.118))
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                }
                            } else {
                                Button {
                                    showPaywall = true
                                } label: {
                                    HStack {
                                        Image(systemName: "photo.on.rectangle.angled")
                                            .foregroundStyle(AppColors.textSecondary)
                                        Text("Photo Timeline")
                                            .foregroundStyle(AppColors.textSecondary)
                                        Spacer()
                                        Image(systemName: "lock.fill")
                                            .foregroundStyle(.yellow)
                                            .font(.caption)
                                        Text("Premium")
                                            .font(.caption)
                                            .foregroundStyle(.yellow)
                                    }
                                    .padding()
                                    .background(Color(red: 0.118, green: 0.118, blue: 0.118))
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                }
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
        .sheet(isPresented: $showHealthCheck) {
            HealthCheckView(plant: plant)
                .presentationDetents([.medium, .large])
        }
    }

    private func performCareAction(_ careType: CareType) {
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()

        WateringService.performCare(type: careType, plant: plant, context: modelContext)

        withAnimation {
            showCheckmark = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            withAnimation {
                showCheckmark = false
            }
        }
    }

    private func reidentifyPlant() {
        guard let data = plant.photoData, let uiImage = UIImage(data: data) else { return }
        isReidentifying = true
        reidentifyResult = nil

        Task {
            let result = await PlantIdentifierService.shared.identifyPlant(from: uiImage)
            await MainActor.run {
                isReidentifying = false
                if let speciesName = result.species {
                    plant.species = speciesName
                    plant.aiConfidence = result.confidence
                    plant.lastIdentifiedDate = Date.now
                    if let dbSpecies = PlantSpeciesDatabase.species(named: speciesName) {
                        plant.wateringIntervalDays = dbSpecies.defaultWateringDays
                    }
                    reidentifyResult = "\(Int(result.confidence * 100))% \(speciesName)"
                    try? modelContext.save()

                    let impact = UIImpactFeedbackGenerator(style: .light)
                    impact.impactOccurred()
                } else {
                    reidentifyResult = "Could not identify"
                }
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
