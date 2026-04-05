import SwiftUI
import SwiftData
import Charts

/// Analytics tab — global dashboard with charts, streaks, and export
struct AnalyticsTabView: View {
    @Query(sort: \Plant.createdAt) var plants: [Plant]
    @Query(sort: \CareLog.logDate, order: .reverse) var allCareLogs: [CareLog]
    @Query(sort: \HealthEntry.date, order: .reverse) var allHealthEntries: [HealthEntry]
    @Query(sort: \DiagnosisEntry.diagnosisDate, order: .reverse) var allDiagnoses: [DiagnosisEntry]
    @Environment(\.modelContext) var modelContext
    @EnvironmentObject var revenueCatManager: RevenueCatManager
    @StateObject private var streakManager = StreakManager.shared

    @State private var showPaywall = false
    @State private var showExportSheet = false
    @State private var exportCSV = ""
    @State private var animateCards = false

    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        // Streak hero
                        streakHero
                            .opacity(animateCards ? 1 : 0)
                            .offset(y: animateCards ? 0 : 15)
                            .animation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.05), value: animateCards)

                        // Quick stats grid
                        statsGrid
                            .opacity(animateCards ? 1 : 0)
                            .offset(y: animateCards ? 0 : 15)
                            .animation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.1), value: animateCards)

                        // Watering activity chart
                        wateringChart
                            .opacity(animateCards ? 1 : 0)
                            .offset(y: animateCards ? 0 : 15)
                            .animation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.15), value: animateCards)

                        // Health overview
                        healthOverview
                            .opacity(animateCards ? 1 : 0)
                            .offset(y: animateCards ? 0 : 15)
                            .animation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.2), value: animateCards)

                        // Most improved plant
                        if let improved = mostImprovedPlant {
                            mostImprovedCard(plant: improved)
                                .opacity(animateCards ? 1 : 0)
                                .offset(y: animateCards ? 0 : 15)
                                .animation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.25), value: animateCards)
                        }

                        // Export button
                        exportSection
                            .opacity(animateCards ? 1 : 0)
                            .offset(y: animateCards ? 0 : 15)
                            .animation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.3), value: animateCards)

                        Spacer(minLength: 40)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                }
            }
            .navigationTitle("Analytics")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    animateCards = true
                }
            }
            .fullScreenCover(isPresented: $showPaywall) {
                PaywallView()
            }
            .sheet(isPresented: $showExportSheet) {
                if !exportCSV.isEmpty {
                    ShareSheetView(text: exportCSV)
                }
            }
            .fullScreenCover(isPresented: $streakManager.showMilestoneCelebration) {
                StreakMilestoneView(days: streakManager.milestoneReached)
            }
        }
    }

    // MARK: - Streak Hero

    private var streakHero: some View {
        VStack(spacing: 16) {
            HStack(spacing: 0) {
                // Current streak
                VStack(spacing: 6) {
                    HStack(spacing: 6) {
                        Image(systemName: "flame.fill")
                            .font(.system(size: 22))
                            .foregroundColor(.orange)
                        Text("\(streakManager.currentStreak)")
                            .font(.system(size: 36, weight: .bold, design: .rounded))
                            .foregroundColor(AppColors.textPrimary)
                    }
                    Text("day streak")
                        .font(.system(.caption, design: .rounded))
                        .foregroundColor(AppColors.textSecondary)
                }
                .frame(maxWidth: .infinity)

                // Divider
                Rectangle()
                    .fill(Color.white.opacity(0.1))
                    .frame(width: 1, height: 48)

                // Longest streak
                VStack(spacing: 6) {
                    HStack(spacing: 6) {
                        Image(systemName: "trophy.fill")
                            .font(.system(size: 18))
                            .foregroundColor(.yellow)
                        Text("\(streakManager.longestStreak)")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(AppColors.textPrimary)
                    }
                    Text("longest")
                        .font(.system(.caption, design: .rounded))
                        .foregroundColor(AppColors.textSecondary)
                }
                .frame(maxWidth: .infinity)

                // Divider
                Rectangle()
                    .fill(Color.white.opacity(0.1))
                    .frame(width: 1, height: 48)

                // Consistency
                VStack(spacing: 6) {
                    Text("\(Int(streakManager.consistencyPercent))%")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(AppColors.limeGreen)
                    Text("consistency")
                        .font(.system(.caption, design: .rounded))
                        .foregroundColor(AppColors.textSecondary)
                }
                .frame(maxWidth: .infinity)
            }

            // Next milestone progress
            if let next = streakManager.nextMilestone, let daysLeft = streakManager.daysToNextMilestone {
                VStack(spacing: 6) {
                    HStack {
                        Text("\(daysLeft) days to \(next)-day milestone")
                            .font(.system(.caption2, design: .rounded))
                            .foregroundColor(AppColors.textSecondary)
                        Spacer()
                        Text("\(streakManager.currentStreak)/\(next)")
                            .font(.system(.caption2, design: .rounded))
                            .fontWeight(.bold)
                            .foregroundColor(.orange)
                    }

                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 3)
                                .fill(Color.white.opacity(0.08))
                                .frame(height: 6)
                            RoundedRectangle(cornerRadius: 3)
                                .fill(
                                    LinearGradient(
                                        colors: [.orange, .yellow],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: geo.size.width * min(CGFloat(streakManager.currentStreak) / CGFloat(next), 1.0), height: 6)
                        }
                    }
                    .frame(height: 6)
                }
            }
        }
        .premiumGlass(cornerRadius: 18, strokeOpacity: 0.10, padding: 16)
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(
                    LinearGradient(
                        colors: [.orange.opacity(0.25), AppColors.emerald.opacity(0.08), Color.white.opacity(0.04)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 0.8
                )
        )
    }

    // MARK: - Stats Grid

    private var statsGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
            AnalyticsStatCard(
                icon: "leaf.fill",
                iconColor: AppColors.forestGreen,
                value: "\(plants.count)",
                label: "Total Plants"
            )

            AnalyticsStatCard(
                icon: "drop.fill",
                iconColor: .blue,
                value: "\(allCareLogs.filter { $0.careType == "water" }.count)",
                label: "Total Waterings"
            )

            AnalyticsStatCard(
                icon: "heart.fill",
                iconColor: .pink,
                value: averageHealthString,
                label: "Avg Health"
            )

            AnalyticsStatCard(
                icon: "stethoscope",
                iconColor: .purple,
                value: "\(allDiagnoses.count)",
                label: "Diagnoses Run"
            )
        }
    }

    private var averageHealthString: String {
        let healthyCount = plants.filter { $0.currentHealth == .healthy }.count
        let total = plants.count
        guard total > 0 else { return "—" }
        let pct = Int(Double(healthyCount) / Double(total) * 100)
        return "\(pct)%"
    }

    // MARK: - Watering Activity Chart

    private var wateringChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("Watering Activity", systemImage: "chart.bar.fill")
                    .font(.system(.subheadline, design: .rounded))
                    .fontWeight(.semibold)
                    .foregroundColor(AppColors.textPrimary)
                Spacer()
                Text("Last 30 days")
                    .font(.system(.caption2, design: .rounded))
                    .foregroundColor(AppColors.textSecondary)
            }

            if revenueCatManager.isPremium || allCareLogs.count <= 10 {
                Chart(wateringChartData, id: \.date) { entry in
                    BarMark(
                        x: .value("Day", entry.date, unit: .day),
                        y: .value("Count", entry.count)
                    )
                    .foregroundStyle(
                        LinearGradient(
                            colors: [AppColors.limeGreen, AppColors.forestGreen],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .cornerRadius(3)
                }
                .chartXAxis {
                    AxisMarks(values: .stride(by: .day, count: 7)) { _ in
                        AxisGridLine(stroke: StrokeStyle(lineWidth: 0.3))
                            .foregroundStyle(Color.white.opacity(0.1))
                        AxisValueLabel(format: .dateTime.month(.abbreviated).day())
                            .foregroundStyle(AppColors.textSecondary)
                    }
                }
                .chartYAxis {
                    AxisMarks { _ in
                        AxisGridLine(stroke: StrokeStyle(lineWidth: 0.3))
                            .foregroundStyle(Color.white.opacity(0.1))
                        AxisValueLabel()
                            .foregroundStyle(AppColors.textSecondary)
                    }
                }
                .frame(height: 180)
            } else {
                // Premium gate
                premiumGateOverlay(text: "Unlock detailed charts", height: 180)
            }
        }
        .padding(16)
        .background(glassBackground)
    }

    private var wateringChartData: [ChartDataPoint] {
        let calendar = Calendar.current
        let thirtyDaysAgo = calendar.date(byAdding: .day, value: -30, to: Date.now)!

        let waterLogs = allCareLogs.filter {
            $0.careType == "water" && $0.logDate >= thirtyDaysAgo
        }

        var grouped: [Date: Int] = [:]
        for i in 0..<30 {
            let day = calendar.startOfDay(for: calendar.date(byAdding: .day, value: -i, to: Date.now)!)
            grouped[day] = 0
        }
        for log in waterLogs {
            let day = calendar.startOfDay(for: log.logDate)
            grouped[day, default: 0] += 1
        }

        return grouped.map { ChartDataPoint(date: $0.key, count: $0.value) }
            .sorted { $0.date < $1.date }
    }

    // MARK: - Health Overview

    private var healthOverview: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Health Overview", systemImage: "heart.text.clipboard")
                .font(.system(.subheadline, design: .rounded))
                .fontWeight(.semibold)
                .foregroundColor(AppColors.textPrimary)

            HStack(spacing: 0) {
                let counts = healthDistribution
                ForEach(Array(counts.enumerated()), id: \.offset) { _, item in
                    VStack(spacing: 6) {
                        Text(item.status.emoji)
                            .font(.system(size: 20))
                        Text("\(item.count)")
                            .font(.system(.headline, design: .rounded))
                            .fontWeight(.bold)
                            .foregroundColor(item.status.color)
                        Text(item.status.displayName)
                            .font(.system(.caption2, design: .rounded))
                            .foregroundColor(AppColors.textSecondary)
                    }
                    .frame(maxWidth: .infinity)
                }
            }

            // Health bar
            GeometryReader { geo in
                HStack(spacing: 2) {
                    let total = max(plants.count, 1)
                    let counts = healthDistribution
                    ForEach(Array(counts.enumerated()), id: \.offset) { _, item in
                        if item.count > 0 {
                            RoundedRectangle(cornerRadius: 3)
                                .fill(item.status.color)
                                .frame(width: geo.size.width * CGFloat(item.count) / CGFloat(total))
                        }
                    }
                }
            }
            .frame(height: 8)
        }
        .padding(16)
        .background(glassBackground)
    }

    private var healthDistribution: [(status: HealthStatus, count: Int)] {
        let statuses: [HealthStatus] = [.healthy, .okay, .struggling, .unknown]
        return statuses.map { status in
            let count = plants.filter { $0.currentHealth == status }.count
            return (status, count)
        }
    }

    // MARK: - Most Improved Plant

    private var mostImprovedPlant: Plant? {
        // Plant with the most health entries showing improvement
        plants
            .filter { $0.healthEntries.count >= 2 }
            .max { a, b in
                improvementScore(for: a) < improvementScore(for: b)
            }
    }

    private func improvementScore(for plant: Plant) -> Int {
        let sorted = plant.healthEntries.sorted { $0.date < $1.date }
        guard sorted.count >= 2,
              let first = sorted.first,
              let last = sorted.last else { return 0 }
        let statusValue: [String: Int] = ["struggling": 0, "unknown": 1, "okay": 2, "healthy": 3]
        let firstVal = statusValue[first.status] ?? 0
        let lastVal = statusValue[last.status] ?? 0
        return lastVal - firstVal
    }

    private func mostImprovedCard(plant: Plant) -> some View {
        HStack(spacing: 12) {
            if let img = plant.photoImage {
                img
                    .resizable()
                    .scaledToFill()
                    .frame(width: 48, height: 48)
                    .clipShape(Circle())
                    .overlay(
                        Circle().stroke(AppColors.limeGreen, lineWidth: 2)
                    )
            } else {
                Circle()
                    .fill(AppColors.forestGreen.opacity(0.3))
                    .frame(width: 48, height: 48)
                    .overlay {
                        Image(systemName: "leaf.fill")
                            .foregroundColor(.white.opacity(0.6))
                    }
            }

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Image(systemName: "arrow.up.right")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(AppColors.limeGreen)
                    Text("Most Improved")
                        .font(.system(.caption, design: .rounded))
                        .fontWeight(.bold)
                        .foregroundColor(AppColors.limeGreen)
                }
                Text(plant.name)
                    .font(.system(.subheadline, design: .rounded))
                    .fontWeight(.semibold)
                    .foregroundColor(AppColors.textPrimary)
                Text("\(plant.healthEntries.count) health checks recorded")
                    .font(.system(.caption2, design: .rounded))
                    .foregroundColor(AppColors.textSecondary)
            }
            Spacer()

            Text(plant.currentHealth.emoji)
                .font(.system(size: 28))
        }
        .padding(14)
        .background(glassBackground)
    }

    // MARK: - Export Section

    private var exportSection: some View {
        VStack(spacing: 12) {
            if revenueCatManager.isPremium {
                Button {
                    exportCSV = generateFullExportCSV()
                    showExportSheet = true
                    let impact = UIImpactFeedbackGenerator(style: .medium)
                    impact.impactOccurred()
                } label: {
                    HStack(spacing: 10) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 16, weight: .semibold))
                        Text("Export All Data (CSV)")
                            .font(.system(.subheadline, design: .rounded))
                            .fontWeight(.bold)
                    }
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 15)
                    .premiumButton()
                }
            } else {
                Button {
                    showPaywall = true
                } label: {
                    HStack(spacing: 10) {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 14))
                        Text("Export All Data")
                            .font(.system(.subheadline, design: .rounded))
                            .fontWeight(.semibold)
                        Spacer()
                        Text("Premium")
                            .font(.system(.caption2, design: .rounded))
                            .fontWeight(.bold)
                            .foregroundColor(.black)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(AppColors.limeGreen)
                            .cornerRadius(4)
                    }
                    .foregroundColor(AppColors.textSecondary)
                    .padding(14)
                    .background(Color.white.opacity(0.05))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white.opacity(0.08), lineWidth: 1)
                    )
                }
            }
        }
    }

    // MARK: - Premium Gate Overlay

    private func premiumGateOverlay(text: String, height: CGFloat) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white.opacity(0.03))
                .frame(height: height)

            VStack(spacing: 10) {
                Image(systemName: "lock.fill")
                    .font(.system(size: 20))
                    .foregroundColor(AppColors.textSecondary)
                Text(text)
                    .font(.system(.caption, design: .rounded))
                    .fontWeight(.medium)
                    .foregroundColor(AppColors.textSecondary)
                Button {
                    showPaywall = true
                } label: {
                    Text("Unlock Premium")
                        .font(.system(.caption2, design: .rounded))
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(AppColors.limeGreen)
                        .cornerRadius(6)
                }
            }
        }
    }

    // MARK: - Glass Background (legacy helper — views migrating to .premiumGlass())

    private var glassBackground: some ShapeStyle {
        .ultraThinMaterial
            .shadow(.inner(color: .white.opacity(0.06), radius: 1, x: 0, y: 1))
            .shadow(.inner(color: .black.opacity(0.15), radius: 2, x: 0, y: -1))
    }

    // MARK: - CSV Export

    private func generateFullExportCSV() -> String {
        var csv = "=== MultiPlant AI Scheduler — Full Export ===\n"
        csv += "Generated: \(Date.now.formatted())\n\n"

        // Plants
        csv += "--- PLANTS ---\n"
        csv += "Name,Species,Room,Watering Interval (days),Last Watered,Health,Streak,Created\n"
        for plant in plants {
            let lastWatered = plant.lastWateredDate?.formatted(date: .abbreviated, time: .omitted) ?? "Never"
            csv += "\"\(plant.name)\",\"\(plant.species ?? "")\",\"\(plant.room ?? "")\",\(plant.wateringIntervalDays),\(lastWatered),\(plant.currentHealth.displayName),\(plant.wateringStreak),\(plant.createdAt.formatted(date: .abbreviated, time: .omitted))\n"
        }

        // Care Logs
        csv += "\n--- CARE LOGS ---\n"
        csv += "Date,Plant,Care Type,Notes\n"
        for log in allCareLogs {
            let date = log.logDate.formatted(date: .abbreviated, time: .shortened)
            csv += "\(date),\"\(log.plant?.name ?? "Unknown")\",\(log.careType),\"\(log.notes ?? "")\"\n"
        }

        // Health Entries
        csv += "\n--- HEALTH ENTRIES ---\n"
        csv += "Date,Plant,Status,Notes\n"
        for entry in allHealthEntries {
            let date = entry.date.formatted(date: .abbreviated, time: .shortened)
            csv += "\(date),\"\(entry.plant?.name ?? "Unknown")\",\(entry.status),\"\(entry.notes ?? "")\"\n"
        }

        // Diagnoses
        csv += "\n--- DIAGNOSES ---\n"
        csv += "Date,Plant,Healthy,Disease,Category,Severity,Confidence\n"
        for diag in allDiagnoses {
            let date = diag.diagnosisDate.formatted(date: .abbreviated, time: .shortened)
            csv += "\(date),\"\(diag.plant?.name ?? "Unlinked")\",\(diag.isHealthy),\"\(diag.diseaseName ?? "")\",\(diag.category),\(diag.severity),\(String(format: "%.0f%%", diag.confidence * 100))\n"
        }

        // Stats
        csv += "\n--- STATS ---\n"
        csv += "Total Plants,\(plants.count)\n"
        csv += "Total Care Logs,\(allCareLogs.count)\n"
        csv += "Current Streak,\(streakManager.currentStreak)\n"
        csv += "Longest Streak,\(streakManager.longestStreak)\n"

        return csv
    }
}

// MARK: - Chart Data Point

struct ChartDataPoint {
    let date: Date
    let count: Int
}

// MARK: - Stat Card

struct AnalyticsStatCard: View {
    let icon: String
    let iconColor: Color
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [iconColor, iconColor.opacity(0.7)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                Text(value)
                    .font(.system(.title2, design: .rounded))
                    .fontWeight(.bold)
                    .foregroundColor(AppColors.textPrimary)
            }
            Text(label)
                .font(.system(.caption2, design: .rounded))
                .foregroundColor(AppColors.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .premiumGlass(cornerRadius: 14, strokeOpacity: 0.08, padding: 16)
    }
}

// MARK: - Share Sheet (UIActivityViewController wrapper)

struct ShareSheetView: UIViewControllerRepresentable {
    let text: String

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let data = text.data(using: .utf8) ?? Data()
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("MultiPlant_Export.csv")
        try? data.write(to: tempURL)
        return UIActivityViewController(activityItems: [tempURL], applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
