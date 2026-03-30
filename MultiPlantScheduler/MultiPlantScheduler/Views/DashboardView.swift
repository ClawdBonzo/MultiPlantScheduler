import SwiftUI
import SwiftData

struct DashboardView: View {
    @Query(sort: \Plant.createdAt) var plants: [Plant]
    @Environment(\.modelContext) var modelContext
    @EnvironmentObject var revenueCatManager: RevenueCatManager

    @State private var showAddPlant = false
    @State private var showSettings = false
    @State private var showPaywall = false
    @State private var showShareGarden = false
    @State private var refreshTrigger = UUID()

    let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    var sortedPlants: [Plant] {
        plants.sorted { plant1, plant2 in
            let urgency1 = plant1.urgencyColor
            let urgency2 = plant2.urgencyColor

            // Sort by urgency: red > yellow > green
            let urgencyOrder: [Color] = [AppColors.urgencyRed, AppColors.urgencyYellow, AppColors.urgencyGreen]
            let index1 = urgencyOrder.firstIndex(of: urgency1) ?? 2
            let index2 = urgencyOrder.firstIndex(of: urgency2) ?? 2

            if index1 != index2 {
                return index1 < index2
            }

            // Then by days until watering
            return plant1.daysUntilWatering < plant2.daysUntilWatering
        }
    }

    var plantsNeedingWaterToday: Int {
        plants.filter { $0.isDueToday || $0.isOverdue }.count
    }

    var maxWateringStreak: Int {
        plants.map { $0.wateringStreak }.max() ?? 0
    }

    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        HStack(spacing: 8) {
                            Image(systemName: "leaf.fill")
                                .foregroundColor(AppColors.limeGreen)
                            Text("My Garden")
                        }
                            .font(.system(.title, design: .rounded))
                            .fontWeight(.bold)
                            .foregroundColor(AppColors.textPrimary)

                        Spacer()

                        HStack(spacing: 12) {
                            if !plants.isEmpty {
                                Button(action: { showShareGarden = true }) {
                                    Image(systemName: "square.and.arrow.up")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(AppColors.limeGreen)
                                }
                            }

                            Button(action: { showSettings = true }) {
                                Image(systemName: "gear")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(AppColors.limeGreen)
                            }

                            Button(action: {
                                if revenueCatManager.canAddPlant(currentCount: plants.count) {
                                    showAddPlant = true
                                } else {
                                    showPaywall = true
                                }
                            }) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(AppColors.limeGreen)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)

                    // Summary badges
                    HStack(spacing: 12) {
                        Badge(
                            label: "\(plants.count) plants",
                            icon: "leaf.fill"
                        )

                        if plantsNeedingWaterToday > 0 {
                            Badge(
                                label: "\(plantsNeedingWaterToday) need water",
                                icon: "droplet.fill",
                                color: AppColors.urgencyRed
                            )
                        }

                        // Cloud credits badge — show when low or empty
                        if !revenueCatManager.isPremium {
                            let credits = CloudIdentificationManager.shared.creditsRemaining
                            if credits <= 3 {
                                Badge(
                                    label: "\(credits) cloud IDs",
                                    icon: "cloud.fill",
                                    color: credits == 0 ? AppColors.urgencyRed : .orange
                                )
                            }
                        }

                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 16)
                }

                // Watering streak banner
                if maxWateringStreak > 0 {
                    HStack(spacing: 8) {
                        HStack(spacing: 4) {
                            Image(systemName: "flame.fill")
                                .foregroundColor(.orange)
                            Text("\(maxWateringStreak) day streak!")
                        }
                            .font(.system(.callout, design: .rounded))
                            .fontWeight(.semibold)
                            .foregroundColor(AppColors.textPrimary)

                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(AppColors.forestGreen.opacity(0.2))
                    .cornerRadius(8)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 16)
                }

                // Today's watering checklist
                if !plants.isEmpty {
                    TodayChecklistView(plants: plants)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 16)
                }

                // Soft nudge when approaching plant limit
                if !revenueCatManager.isPremium && plants.count >= 2 && plants.count < AppConfig.freePlantLimit {
                    Button {
                        showPaywall = true
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "sparkles")
                                .foregroundColor(AppColors.limeGreen)

                            Text("You have \(plants.count)/\(AppConfig.freePlantLimit) free plants — Upgrade for unlimited + Cloud AI")
                                .font(.system(.caption, design: .rounded))
                                .fontWeight(.medium)
                                .foregroundColor(AppColors.textSecondary)
                                .lineLimit(2)

                            Spacer()

                            Image(systemName: "chevron.right")
                                .font(.system(size: 10, weight: .semibold))
                                .foregroundColor(AppColors.textSecondary)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                        .background(AppColors.limeGreen.opacity(0.08))
                        .cornerRadius(8)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 12)
                }

                // Free plan upgrade banner
                if !revenueCatManager.isPremium && plants.count >= AppConfig.freePlantLimit {
                    HStack(spacing: 8) {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)

                        VStack(alignment: .leading, spacing: 2) {
                            Text("Upgrade to Premium")
                                .font(.system(.caption, design: .rounded))
                                .fontWeight(.semibold)
                                .foregroundColor(AppColors.textPrimary)

                            Text("From $3.99/mo or $49.99 lifetime")
                                .font(.system(.caption2, design: .rounded))
                                .foregroundColor(AppColors.textSecondary)
                        }

                        Spacer()

                        Image(systemName: "chevron.right")
                            .foregroundColor(AppColors.textSecondary)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 12)
                    .background(AppColors.forestGreen.opacity(0.15))
                    .cornerRadius(8)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 16)
                    .onTapGesture {
                        showPaywall = true
                    }
                }

                if plants.isEmpty {
                    // Empty state — invites user to AI-identify their first plant
                    VStack(spacing: 24) {
                        Spacer()

                        VStack(spacing: 16) {
                            Image(systemName: "camera.viewfinder")
                                .font(.system(size: 56, weight: .ultraLight))
                                .foregroundColor(AppColors.limeGreen)

                            Text("Your Garden Is Empty")
                                .font(.system(.title2, design: .rounded))
                                .fontWeight(.bold)
                                .foregroundColor(AppColors.textPrimary)

                            Text("Snap a photo of a plant and let AI\nidentify it and set up care reminders")
                                .font(.system(.subheadline, design: .rounded))
                                .foregroundColor(AppColors.textSecondary)
                                .multilineTextAlignment(.center)
                        }

                        Button(action: { showAddPlant = true }) {
                            HStack(spacing: 8) {
                                Image(systemName: "camera.fill")
                                Text("Add Your First Plant")
                            }
                                .font(.system(.headline, design: .rounded))
                                .fontWeight(.semibold)
                                .foregroundColor(AppColors.background)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(AppColors.limeGreen)
                                .cornerRadius(12)
                        }
                        .padding(.horizontal, 40)

                        Spacer()
                    }
                    .padding(.horizontal, 20)
                } else {
                    // Plant grid
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 16) {
                            ForEach(sortedPlants) { plant in
                                NavigationLink(value: plant) {
                                    PlantCardView(plant: plant)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(20)
                    }
                    .refreshable {
                        refreshTrigger = UUID()
                        try? modelContext.save()
                    }
                    .navigationDestination(for: Plant.self) { plant in
                        PlantDetailView(plant: plant)
                    }
                }
            }
        }
        .sheet(isPresented: $showAddPlant) {
            AddPlantView()
                .presentationDetents([.large])
        }
        .sheet(isPresented: $showSettings) {
            NavigationStack {
                SettingsView()
            }
            .presentationDetents([.large])
        }
        .sheet(isPresented: $showPaywall) {
            PaywallView()
                .presentationDetents([.medium, .large])
        }
        .sheet(isPresented: $showShareGarden) {
            ShareGardenView(plants: plants)
        }
    }
}

struct Badge: View {
    let label: String
    let icon: String
    var color: Color = AppColors.limeGreen

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .semibold))

            Text(label)
                .font(.system(.caption, design: .rounded))
                .fontWeight(.semibold)
        }
        .foregroundColor(.white)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(color)
        .cornerRadius(8)
    }
}

#Preview {
    DashboardView()
        .environmentObject(RevenueCatManager.shared)
}
