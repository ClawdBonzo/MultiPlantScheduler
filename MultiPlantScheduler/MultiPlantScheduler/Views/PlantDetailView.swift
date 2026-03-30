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
    @State private var showHealthCheck = false
    @State private var showHealthHistory = false
    @State private var showWateringSheet = false
    @State private var isReidentifying = false
    @State private var reidentifyResult: String?
    @State private var careButtonScales: [String: CGFloat] = [:]
    @State private var showAllCareLogs = false
    @State private var appeared = false
    @State private var isCloudIdentifying = false
    @State private var cloudIDUsed = false
    @State private var showUpgradeForCloud = false

    var adjustedWateringInterval: Int {
        SeasonalAdjuster.adjustedInterval(baseInterval: plant.wateringIntervalDays)
    }

    var sortedCareLogs: [CareLog] {
        plant.careLogs.sorted { $0.logDate > $1.logDate }
    }

    var nextWateringText: String {
        let days = plant.daysUntilWatering
        let dateStr = plant.nextWateringDate.formatted(.dateTime.month(.abbreviated).day())
        if days < 0 {
            return "Overdue by \(abs(days)) day\(abs(days) == 1 ? "" : "s")"
        } else if days == 0 {
            return "Due today"
        } else {
            return "In \(days) day\(days == 1 ? "" : "s") (\(dateStr))"
        }
    }

    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 0) {
                    // MARK: - Hero Photo + Floating Re-identify
                    ZStack(alignment: .topTrailing) {
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
                        .frame(height: 260)
                        .clipped()

                        // Floating Re-identify button
                        if plant.photoData != nil {
                            Button {
                                reidentifyPlant()
                            } label: {
                                ZStack {
                                    Circle()
                                        .fill(.ultraThinMaterial)
                                        .frame(width: 44, height: 44)
                                        .shadow(color: .black.opacity(0.3), radius: 8, y: 4)

                                    if isReidentifying {
                                        ProgressView()
                                            .tint(AppColors.limeGreen)
                                            .scaleEffect(0.7)
                                    } else {
                                        Image(systemName: "brain")
                                            .font(.system(size: 18, weight: .semibold))
                                            .foregroundStyle(AppColors.limeGreen)
                                    }
                                }
                            }
                            .disabled(isReidentifying)
                            .padding(.top, 12)
                            .padding(.trailing, 16)
                            .transition(.scale.combined(with: .opacity))
                        }
                    }

                    VStack(spacing: 20) {
                        // MARK: - Next Watering Badge
                        Button {
                            showWateringSheet = true
                        } label: {
                            HStack(spacing: 12) {
                                ZStack {
                                    Circle()
                                        .fill(plant.urgencyColor.opacity(0.2))
                                        .frame(width: 44, height: 44)

                                    Image(systemName: "drop.fill")
                                        .font(.system(size: 20, weight: .semibold))
                                        .foregroundStyle(plant.urgencyColor)
                                }

                                VStack(alignment: .leading, spacing: 3) {
                                    Text("Next Watering")
                                        .font(.system(.caption, design: .rounded))
                                        .fontWeight(.medium)
                                        .foregroundColor(AppColors.textSecondary)

                                    Text(nextWateringText)
                                        .font(.system(.body, design: .rounded))
                                        .fontWeight(.bold)
                                        .foregroundColor(plant.urgencyColor)
                                }

                                Spacer()

                                Image(systemName: "chevron.right")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(AppColors.textSecondary)
                            }
                            .padding(16)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(plant.urgencyColor.opacity(0.08))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(plant.urgencyColor.opacity(0.2), lineWidth: 1)
                                    )
                            )
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, -20)
                        .offset(y: appeared ? 0 : 20)
                        .opacity(appeared ? 1 : 0)

                        // MARK: - Plant Info
                        VStack(alignment: .leading, spacing: 12) {
                            Text(plant.name)
                                .font(.system(.title, design: .rounded))
                                .fontWeight(.bold)
                                .foregroundColor(AppColors.textPrimary)

                            VStack(alignment: .leading, spacing: 8) {
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

                                // Last watered + Added dates
                                if let lastWatered = plant.lastWateredDate {
                                    InfoRow(label: "Last Watered", value: lastWatered.formatted(date: .abbreviated, time: .omitted))
                                }
                                InfoRow(label: "Added", value: plant.createdAt.formatted(date: .abbreviated, time: .omitted))

                                // Tappable Health row
                                Button {
                                    showHealthHistory = true
                                } label: {
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
                                            Image(systemName: "chevron.right")
                                                .font(.system(size: 10, weight: .semibold))
                                                .foregroundColor(AppColors.textSecondary)
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

                                // Cloud ID button + credits badge
                                if plant.photoData != nil && !cloudIDUsed {
                                    VStack(spacing: 8) {
                                        if isCloudIdentifying {
                                            HStack(spacing: 8) {
                                                ProgressView()
                                                    .tint(AppColors.limeGreen)
                                                    .scaleEffect(0.8)
                                                Text("Getting precise ID...")
                                                    .font(.system(.caption, design: .rounded))
                                                    .fontWeight(.medium)
                                                    .foregroundColor(AppColors.textSecondary)
                                            }
                                            .padding(10)
                                            .frame(maxWidth: .infinity)
                                            .background(AppColors.limeGreen.opacity(0.1))
                                            .clipShape(RoundedRectangle(cornerRadius: 10))
                                        } else {
                                            Button {
                                                getPreciseCloudID()
                                            } label: {
                                                HStack(spacing: 8) {
                                                    Image(systemName: "cloud.fill")
                                                        .font(.system(size: 14, weight: .semibold))
                                                    Text("Get Precise ID")
                                                        .font(.system(.caption, design: .rounded))
                                                        .fontWeight(.bold)

                                                    Spacer()

                                                    let credits = CloudIdentificationManager.shared.creditsRemaining
                                                    if revenueCatManager.isPremium {
                                                        Text("Unlimited")
                                                            .font(.system(.caption2, design: .rounded))
                                                            .fontWeight(.semibold)
                                                            .foregroundStyle(.white.opacity(0.7))
                                                    } else {
                                                        Text("\(credits)/\(CloudIdentificationManager.maxFreeCredits) free")
                                                            .font(.system(.caption2, design: .rounded))
                                                            .fontWeight(.semibold)
                                                            .foregroundStyle(.white.opacity(0.7))
                                                    }
                                                }
                                                .foregroundStyle(.white)
                                                .padding(.horizontal, 14)
                                                .padding(.vertical, 10)
                                                .background(
                                                    LinearGradient(
                                                        colors: [AppColors.forestGreen, AppColors.limeGreen],
                                                        startPoint: .leading,
                                                        endPoint: .trailing
                                                    )
                                                )
                                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                            }
                                        }
                                    }
                                    .padding(.vertical, 4)
                                }

                                // Re-identify result
                                if let result = reidentifyResult {
                                    HStack(spacing: 6) {
                                        Image(systemName: "checkmark.circle.fill")
                                            .font(.system(size: 12))
                                            .foregroundStyle(AppColors.limeGreen)
                                        Text(result)
                                            .font(.system(.caption, design: .rounded))
                                            .fontWeight(.medium)
                                            .foregroundColor(AppColors.limeGreen)
                                    }
                                    .padding(8)
                                    .background(AppColors.limeGreen.opacity(0.1))
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                    .transition(.scale.combined(with: .opacity))
                                }

                                // Cloud credits badge (always visible)
                                HStack(spacing: 6) {
                                    Image(systemName: "cloud.fill")
                                        .font(.system(size: 11, weight: .semibold))
                                        .foregroundColor(revenueCatManager.isPremium ? AppColors.limeGreen : .orange)
                                    if revenueCatManager.isPremium {
                                        Text("Cloud Credits: Unlimited")
                                            .font(.system(.caption2, design: .rounded))
                                            .fontWeight(.medium)
                                            .foregroundColor(AppColors.textSecondary)
                                    } else {
                                        Text("Cloud Credits: \(CloudIdentificationManager.shared.creditsRemaining)/\(CloudIdentificationManager.maxFreeCredits) free")
                                            .font(.system(.caption2, design: .rounded))
                                            .fontWeight(.medium)
                                            .foregroundColor(CloudIdentificationManager.shared.creditsRemaining <= 3 ? .orange : AppColors.textSecondary)
                                    }
                                }
                                .padding(.vertical, 2)

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
                        }
                        .padding(.horizontal, 20)

                        // MARK: - Quick Care Buttons
                        VStack(spacing: 12) {
                            Text("Quick Care")
                                .font(.system(.headline, design: .rounded))
                                .fontWeight(.semibold)
                                .foregroundColor(AppColors.textPrimary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, 20)

                            HStack(spacing: 8) {
                                ForEach([CareType.water, CareType.fertilize, CareType.mist, CareType.repot], id: \.rawValue) { careType in
                                    Button(action: {
                                        performCareAction(careType)
                                    }) {
                                        VStack(spacing: 8) {
                                            Image(systemName: careType.iconName)
                                                .font(.system(size: 22, weight: .semibold))

                                            Text(careType.label)
                                                .font(.system(size: 11, weight: .bold, design: .rounded))
                                                .lineLimit(1)
                                        }
                                        .frame(maxWidth: .infinity)
                                        .foregroundColor(.white)
                                        .padding(.vertical, 16)
                                        .background(
                                            RoundedRectangle(cornerRadius: 14)
                                                .fill(careType.color)
                                                .shadow(color: careType.color.opacity(0.4), radius: 6, y: 3)
                                        )
                                    }
                                    .scaleEffect(careButtonScales[careType.rawValue] ?? 1.0)
                                }

                                // Health check button
                                Button(action: {
                                    let impact = UIImpactFeedbackGenerator(style: .medium)
                                    impact.impactOccurred()
                                    withAnimation(.spring(response: 0.2, dampingFraction: 0.5)) {
                                        careButtonScales["health"] = 0.85
                                    }
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                                        withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                                            careButtonScales["health"] = 1.0
                                        }
                                    }
                                    showHealthCheck = true
                                }) {
                                    VStack(spacing: 8) {
                                        Image(systemName: "heart.fill")
                                            .font(.system(size: 22, weight: .semibold))

                                        Text("Health")
                                            .font(.system(size: 11, weight: .bold, design: .rounded))
                                            .lineLimit(1)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .foregroundColor(.white)
                                    .padding(.vertical, 16)
                                    .background(
                                        RoundedRectangle(cornerRadius: 14)
                                            .fill(Color.pink)
                                            .shadow(color: Color.pink.opacity(0.4), radius: 6, y: 3)
                                    )
                                }
                                .scaleEffect(careButtonScales["health"] ?? 1.0)
                            }
                            .padding(.horizontal, 20)
                        }

                        // MARK: - Stats
                        HStack(spacing: 16) {
                            StatCard(label: "Streak", value: "\(plant.wateringStreak)", icon: "🔥")
                            StatCard(label: "Care Logs", value: "\(plant.careLogs.count)", icon: "📋")
                        }
                        .padding(.horizontal, 20)

                        // MARK: - Photo Timeline Teaser
                        VStack(spacing: 10) {
                            // Photo teaser — always visible
                            if revenueCatManager.isPremium {
                                NavigationLink {
                                    PhotoTimelineView(plant: plant)
                                } label: {
                                    photoTimelineRow(locked: false)
                                }
                            } else {
                                Button {
                                    showPaywall = true
                                } label: {
                                    photoTimelineRow(locked: true)
                                }
                            }

                            // Health History link
                            Button {
                                showHealthHistory = true
                            } label: {
                                HStack(spacing: 12) {
                                    Image(systemName: "heart.text.clipboard")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundStyle(.pink)
                                    Text("Health History")
                                        .font(.system(.body, design: .rounded))
                                        .fontWeight(.medium)
                                        .foregroundStyle(AppColors.textPrimary)
                                    Spacer()
                                    if !plant.healthEntries.isEmpty {
                                        Text("\(plant.healthEntries.count)")
                                            .font(.system(.caption, design: .rounded))
                                            .foregroundStyle(AppColors.textSecondary)
                                    }
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundStyle(AppColors.textSecondary)
                                }
                                .padding(16)
                                .background(Color(red: 0.118, green: 0.118, blue: 0.118))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                        }
                        .padding(.horizontal, 20)

                        // MARK: - Care History
                        if !sortedCareLogs.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Text("Care History")
                                        .font(.system(.headline, design: .rounded))
                                        .fontWeight(.semibold)
                                        .foregroundColor(AppColors.textPrimary)

                                    Spacer()

                                    if sortedCareLogs.count > 3 {
                                        Button {
                                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                                showAllCareLogs.toggle()
                                            }
                                        } label: {
                                            Text(showAllCareLogs ? "Show Less" : "View All (\(sortedCareLogs.count))")
                                                .font(.system(.caption, design: .rounded))
                                                .fontWeight(.semibold)
                                                .foregroundColor(AppColors.limeGreen)
                                        }
                                    }
                                }

                                let logsToShow = showAllCareLogs ? sortedCareLogs : Array(sortedCareLogs.prefix(3))
                                VStack(spacing: 8) {
                                    ForEach(logsToShow) { log in
                                        CareLogRow(log: log)
                                            .transition(.opacity.combined(with: .move(edge: .top)))
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                        }

                        // MARK: - Export
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
                .presentationDetents([.large])
                .interactiveDismissDisabled(false)
        }
        .sheet(isPresented: $showHealthCheck) {
            HealthCheckView(plant: plant)
                .presentationDetents([.medium, .large])
        }
        .sheet(isPresented: $showHealthHistory) {
            NavigationStack {
                HealthTimelineView(plant: plant)
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button("Done") { showHealthHistory = false }
                                .font(.system(.body, design: .rounded))
                                .fontWeight(.semibold)
                                .foregroundColor(AppColors.limeGreen)
                        }
                    }
            }
        }
        .sheet(isPresented: $showWateringSheet) {
            WateringSettingsSheet(plant: plant)
                .presentationDetents([.medium])
        }
        .alert("Cloud IDs Used", isPresented: $showUpgradeForCloud) {
            Button("Upgrade to Premium") { showPaywall = true }
            Button("OK", role: .cancel) { }
        } message: {
            Text("You've used all \(CloudIdentificationManager.maxFreeCredits) free cloud identifications. Upgrade to Premium for unlimited precise plant IDs!")
        }
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.1)) {
                appeared = true
            }
        }
    }

    // MARK: - Photo Timeline Teaser Row

    @ViewBuilder
    private func photoTimelineRow(locked: Bool) -> some View {
        HStack(spacing: 12) {
            // Show hero photo as teaser thumbnail
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(AppColors.forestGreen.opacity(0.3))
                    .frame(width: 48, height: 48)

                if let photoImage = plant.photoImage {
                    photoImage
                        .resizable()
                        .scaledToFill()
                        .frame(width: 48, height: 48)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                } else {
                    Image(systemName: "photo.on.rectangle.angled")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(locked ? AppColors.textSecondary : AppColors.limeGreen)
                }
            }

            VStack(alignment: .leading, spacing: 3) {
                Text("Photo Timeline")
                    .font(.system(.body, design: .rounded))
                    .fontWeight(.medium)
                    .foregroundStyle(locked ? AppColors.textSecondary : AppColors.textPrimary)

                Text(locked
                    ? "Track growth over time"
                    : "\(plant.photoEntries.count) photo\(plant.photoEntries.count == 1 ? "" : "s")")
                    .font(.system(.caption, design: .rounded))
                    .foregroundStyle(AppColors.textSecondary)
            }

            Spacer()

            if locked {
                HStack(spacing: 4) {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 10))
                    Text("Premium")
                        .font(.system(size: 11, weight: .semibold))
                }
                .foregroundStyle(.yellow)
            } else {
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(AppColors.textSecondary)
            }
        }
        .padding(16)
        .background(Color(red: 0.118, green: 0.118, blue: 0.118))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Quick Care

    private func performCareAction(_ careType: CareType) {
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()

        // Scale animation
        withAnimation(.spring(response: 0.2, dampingFraction: 0.5)) {
            careButtonScales[careType.rawValue] = 0.85
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                careButtonScales[careType.rawValue] = 1.0
            }
        }

        WateringService.performCare(type: careType, plant: plant, context: modelContext)

        // Success haptic after brief delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            let success = UINotificationFeedbackGenerator()
            success.notificationOccurred(.success)
        }
    }

    // MARK: - Re-identify

    private func reidentifyPlant() {
        guard let data = plant.photoData, let uiImage = UIImage(data: data) else { return }
        isReidentifying = true
        reidentifyResult = nil

        let impact = UIImpactFeedbackGenerator(style: .light)
        impact.impactOccurred()

        Task {
            let result = await PlantIdentifierService.shared.identifyPlant(from: uiImage)
            await MainActor.run {
                isReidentifying = false
                if let speciesName = result.species {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                        plant.species = speciesName
                        plant.aiConfidence = result.confidence
                        plant.lastIdentifiedDate = Date.now
                        if let dbSpecies = PlantSpeciesDatabase.species(named: speciesName) {
                            plant.wateringIntervalDays = dbSpecies.defaultWateringDays
                        }
                        reidentifyResult = "\(Int(result.confidence * 100))% \(speciesName)"
                    }
                    try? modelContext.save()

                    let success = UINotificationFeedbackGenerator()
                    success.notificationOccurred(.success)
                } else {
                    reidentifyResult = "Could not identify"
                }
            }
        }
    }

    // MARK: - Cloud Precise ID

    private func getPreciseCloudID() {
        guard let data = plant.photoData, let uiImage = UIImage(data: data) else { return }

        #if DEBUG
        print("☁️ PlantDetail — 'Get Precise ID' tapped for plant: \(plant.name)")
        #endif

        let cloud = CloudIdentificationManager.shared
        guard cloud.canUseCloud(isPremium: revenueCatManager.isPremium) else {
            showUpgradeForCloud = true
            return
        }

        isCloudIdentifying = true
        let impact = UIImpactFeedbackGenerator(style: .light)
        impact.impactOccurred()

        Task {
            if let cloudResult = await cloud.identifyPlant(from: uiImage, isPremium: revenueCatManager.isPremium) {
                let result = cloud.toIdentificationResult(cloudResult)
                await MainActor.run {
                    isCloudIdentifying = false
                    cloudIDUsed = true

                    #if DEBUG
                    print("☁️ PlantDetail — cloud result: \(result.species ?? "nil") @ \(Int(result.confidence * 100))%")
                    print("☁️ PlantDetail — credits after call: \(CloudIdentificationManager.shared.creditsRemaining)")
                    #endif

                    if let speciesName = result.species {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                            plant.species = speciesName
                            plant.aiConfidence = result.confidence
                            plant.lastIdentifiedDate = Date.now
                            plant.wateringIntervalDays = result.defaultInterval
                            reidentifyResult = "Cloud AI: \(Int(result.confidence * 100))% \(speciesName)"
                        }
                        try? modelContext.save()
                        let success = UINotificationFeedbackGenerator()
                        success.notificationOccurred(.success)
                    } else {
                        reidentifyResult = "Cloud AI could not identify"
                    }
                }
            } else {
                await MainActor.run {
                    isCloudIdentifying = false
                    if !cloud.isAPIKeyConfigured {
                        reidentifyResult = "Cloud AI not configured — check Config.xcconfig"
                    } else if let errorMsg = cloud.lastErrorMessage {
                        reidentifyResult = errorMsg
                    } else {
                        reidentifyResult = "Cloud ID unavailable — try again"
                    }

                    #if DEBUG
                    print("☁️ PlantDetail — cloud call failed: \(cloud.lastErrorMessage ?? "unknown")")
                    #endif
                }
            }
        }
    }

    // MARK: - Delete

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

    // MARK: - CSV Export

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

// MARK: - Watering Settings Sheet

struct WateringSettingsSheet: View {
    @Bindable var plant: Plant
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss
    @State private var interval: Int

    init(plant: Plant) {
        self.plant = plant
        _interval = State(initialValue: plant.wateringIntervalDays)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background.ignoresSafeArea()

                VStack(spacing: 24) {
                    // Urgency indicator
                    ZStack {
                        Circle()
                            .fill(plant.urgencyColor.opacity(0.15))
                            .frame(width: 80, height: 80)

                        Image(systemName: "drop.fill")
                            .font(.system(size: 32, weight: .semibold))
                            .foregroundStyle(plant.urgencyColor)
                    }

                    VStack(spacing: 6) {
                        Text("Next Watering")
                            .font(.system(.headline, design: .rounded))
                            .foregroundColor(AppColors.textPrimary)

                        Text(plant.nextWateringDate.formatted(date: .long, time: .omitted))
                            .font(.system(.body, design: .rounded))
                            .foregroundColor(AppColors.textSecondary)
                    }

                    // Interval adjuster
                    VStack(spacing: 12) {
                        Text("Watering Interval")
                            .font(.system(.caption, design: .rounded))
                            .fontWeight(.medium)
                            .foregroundColor(AppColors.textSecondary)

                        HStack(spacing: 20) {
                            Button {
                                if interval > 1 {
                                    interval -= 1
                                    let impact = UIImpactFeedbackGenerator(style: .light)
                                    impact.impactOccurred()
                                }
                            } label: {
                                Image(systemName: "minus.circle.fill")
                                    .font(.system(size: 32))
                                    .foregroundStyle(AppColors.limeGreen)
                            }

                            Text("\(interval) days")
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                                .foregroundColor(AppColors.limeGreen)
                                .frame(minWidth: 100)

                            Button {
                                if interval < 60 {
                                    interval += 1
                                    let impact = UIImpactFeedbackGenerator(style: .light)
                                    impact.impactOccurred()
                                }
                            } label: {
                                Image(systemName: "plus.circle.fill")
                                    .font(.system(size: 32))
                                    .foregroundStyle(AppColors.limeGreen)
                            }
                        }
                    }
                    .padding(20)
                    .background(Color(red: 0.118, green: 0.118, blue: 0.118))
                    .cornerRadius(16)

                    // Water now button
                    Button {
                        WateringService.performCare(type: .water, plant: plant, context: modelContext)
                        let success = UINotificationFeedbackGenerator()
                        success.notificationOccurred(.success)
                        dismiss()
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "drop.fill")
                            Text("Water Now")
                                .fontWeight(.bold)
                        }
                        .font(.system(.body, design: .rounded))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(AppColors.limeGreen)
                        .cornerRadius(12)
                    }

                    Spacer()
                }
                .padding(24)
            }
            .navigationTitle("Watering Schedule")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        plant.wateringIntervalDays = interval
                        try? modelContext.save()
                        Task {
                            await NotificationManager.shared.scheduleReminder(for: plant)
                        }
                        let impact = UIImpactFeedbackGenerator(style: .medium)
                        impact.impactOccurred()
                        dismiss()
                    }
                    .font(.system(.body, design: .rounded))
                    .fontWeight(.semibold)
                    .foregroundColor(AppColors.limeGreen)
                }

                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                        .font(.system(.body, design: .rounded))
                        .foregroundColor(AppColors.textSecondary)
                }
            }
        }
    }
}

// MARK: - Helper Views

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
