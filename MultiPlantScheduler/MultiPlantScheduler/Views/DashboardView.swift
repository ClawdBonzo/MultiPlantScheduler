import SwiftUI
import SwiftData

struct DashboardView: View {
    @Query(sort: \Plant.createdAt) var plants: [Plant]
    @Environment(\.modelContext) var modelContext
    @EnvironmentObject var revenueCatManager: RevenueCatManager

    @State private var showAddPlant = false
    @State private var showPaywall = false
    @State private var showShareGarden = false
    @State private var refreshTrigger = UUID()

    let columns = [
        GridItem(.flexible(), spacing: 14),
        GridItem(.flexible(), spacing: 14)
    ]

    var sortedPlants: [Plant] {
        plants.sorted { plant1, plant2 in
            let urgency1 = plant1.urgencyColor
            let urgency2 = plant2.urgencyColor

            let urgencyOrder: [Color] = [AppColors.urgencyRed, AppColors.urgencyYellow, AppColors.urgencyGreen]
            let index1 = urgencyOrder.firstIndex(of: urgency1) ?? 2
            let index2 = urgencyOrder.firstIndex(of: urgency2) ?? 2

            if index1 != index2 {
                return index1 < index2
            }

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

            // Subtle ambient glow behind content
            VStack {
                Circle()
                    .fill(AppColors.emerald.opacity(0.06))
                    .blur(radius: 80)
                    .frame(width: 300, height: 300)
                    .offset(x: -60, y: -120)
                Spacer()
            }
            .ignoresSafeArea()
            .allowsHitTesting(false)

            VStack(spacing: 0) {
                // Header
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        HStack(spacing: 8) {
                            Image(systemName: "leaf.fill")
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [AppColors.emerald, AppColors.limeGreen],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
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
                                        .foregroundColor(AppColors.emerald)
                                }
                            }

                            Button(action: {
                                if revenueCatManager.canAddPlant(currentCount: plants.count) {
                                    showAddPlant = true
                                } else {
                                    showPaywall = true
                                }
                            }) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.system(size: 22))
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: [AppColors.emerald, AppColors.limeGreen],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)

                    // Summary badges
                    HStack(spacing: 10) {
                        DashboardBadge(
                            label: String(format: NSLocalizedString("%d plants", comment: "Plant count badge"), plants.count),
                            icon: "leaf.fill"
                        )

                        if plantsNeedingWaterToday > 0 {
                            DashboardBadge(
                                label: String(format: NSLocalizedString("%d need water", comment: "Plants needing water"), plantsNeedingWaterToday),
                                icon: "droplet.fill",
                                color: AppColors.urgencyRed
                            )
                        }

                        if !revenueCatManager.isPremium {
                            let credits = CloudIdentificationManager.shared.creditsRemaining
                            if credits <= 3 {
                                DashboardBadge(
                                    label: String(format: NSLocalizedString("%d cloud IDs", comment: "Cloud credits badge"), credits),
                                    icon: "cloud.fill",
                                    color: credits == 0 ? AppColors.urgencyRed : AppColors.urgencyWarning
                                )
                            }
                        }

                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 14)
                }

                // Watering streak banner
                if maxWateringStreak > 0 {
                    HStack(spacing: 8) {
                        HStack(spacing: 5) {
                            Image(systemName: "flame.fill")
                                .foregroundColor(.orange)
                            Text(String(format: NSLocalizedString("%d day streak!", comment: "Watering streak"), maxWateringStreak))
                        }
                            .font(.system(.callout, design: .rounded))
                            .fontWeight(.semibold)
                            .foregroundColor(AppColors.textPrimary)

                        Spacer()
                    }
                    .premiumGlass(cornerRadius: 12, strokeOpacity: 0.08, padding: 14)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 14)
                    .animatedEntrance(delay: 0.05)
                }

                // Today's watering checklist
                if !plants.isEmpty {
                    TodayChecklistView(plants: plants)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 14)
                        .animatedEntrance(delay: 0.1)
                }

                // Soft nudge
                if !revenueCatManager.isPremium && plants.count >= 2 && plants.count < AppConfig.freePlantLimit {
                    Button {
                        showPaywall = true
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "sparkles")
                                .foregroundColor(AppColors.emerald)

                            Text(String(format: NSLocalizedString("You have %d/%d free plants — Upgrade for unlimited + Cloud AI", comment: "Soft upgrade nudge"), plants.count, AppConfig.freePlantLimit))
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
                        .background(AppColors.emerald.opacity(0.08))
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(AppColors.emerald.opacity(0.15), lineWidth: 0.5)
                        )
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 12)
                }

                // Premium upgrade banner
                if !revenueCatManager.isPremium && plants.count >= AppConfig.freePlantLimit {
                    HStack(spacing: 10) {
                        Image(systemName: "crown.fill")
                            .foregroundColor(.yellow)
                            .font(.system(size: 16))

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
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(AppColors.textSecondary)
                    }
                    .premiumGlass(cornerRadius: 14, strokeOpacity: 0.1, padding: 14)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 14)
                    .onTapGesture {
                        showPaywall = true
                    }
                }

                if plants.isEmpty {
                    // Empty state
                    VStack(spacing: 28) {
                        Spacer()

                        VStack(spacing: 18) {
                            ZStack {
                                Circle()
                                    .fill(AppColors.emerald.opacity(0.08))
                                    .frame(width: 100, height: 100)

                                Image(systemName: "camera.viewfinder")
                                    .font(.system(size: 44, weight: .ultraLight))
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: [AppColors.emerald, AppColors.limeGreen],
                                            startPoint: .top,
                                            endPoint: .bottom
                                        )
                                    )
                            }

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
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 15)
                                .premiumButton()
                        }
                        .padding(.horizontal, 40)

                        Spacer()
                    }
                    .padding(.horizontal, 20)
                } else {
                    // Plant grid
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 14) {
                            ForEach(Array(sortedPlants.enumerated()), id: \.element.id) { index, plant in
                                NavigationLink(value: plant) {
                                    PlantCardView(plant: plant)
                                        .animatedEntrance(delay: 0.05 + Double(min(index, 10)) * 0.04)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 4)
                        .padding(.bottom, 20)
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
        .fullScreenCover(isPresented: $showPaywall) {
            PaywallView()
        }
        .sheet(isPresented: $showShareGarden) {
            ShareGardenView(plants: plants)
        }
    }
}

// MARK: - Dashboard Badge

struct DashboardBadge: View {
    let label: String
    let icon: String
    var color: Color = AppColors.emerald

    var body: some View {
        HStack(spacing: 5) {
            Image(systemName: icon)
                .font(.system(size: 12, weight: .semibold))

            Text(label)
                .font(.system(.caption, design: .rounded))
                .fontWeight(.semibold)
        }
        .foregroundColor(.white)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(
            Capsule().fill(color)
        )
        .shadow(color: color.opacity(0.3), radius: 6, y: 2)
    }
}

// Keep the old Badge name working for any other references
typealias Badge = DashboardBadge

#Preview {
    DashboardView()
        .environmentObject(RevenueCatManager.shared)
}
