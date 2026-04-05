import SwiftUI
import SwiftData
import Charts

/// Per-plant analytics sheet — individual streak, health trend, care summary, export
struct PlantAnalyticsView: View {
    let plant: Plant
    @EnvironmentObject var revenueCatManager: RevenueCatManager
    @Environment(\.dismiss) var dismiss

    @State private var showPaywall = false
    @State private var showExport = false
    @State private var exportCSV = ""

    // MARK: - Computed

    private var sortedCareLogs: [CareLog] {
        plant.careLogs.sorted { $0.logDate > $1.logDate }
    }

    private var sortedHealthEntries: [HealthEntry] {
        plant.healthEntries.sorted { $0.date < $1.date }
    }

    private var wateringCount: Int {
        plant.careLogs.filter { $0.careType == "water" }.count
    }

    private var fertilizeCount: Int {
        plant.careLogs.filter { $0.careType == "fertilize" }.count
    }

    private var daysSinceCreated: Int {
        max(1, Calendar.current.dateComponents([.day], from: plant.createdAt, to: Date.now).day ?? 1)
    }

    private var avgWateringFrequency: String {
        guard wateringCount > 1 else { return "—" }
        let waterLogs = plant.careLogs.filter { $0.careType == "water" }.sorted { $0.logDate < $1.logDate }
        var totalGap = 0.0
        for i in 1..<waterLogs.count {
            totalGap += waterLogs[i].logDate.timeIntervalSince(waterLogs[i-1].logDate)
        }
        let avgDays = totalGap / Double(waterLogs.count - 1) / 86400
        return String(format: "%.1f days", avgDays)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        // Plant header
                        plantHeader

                        // Stats row
                        statsRow

                        // Health trend chart
                        healthTrendChart

                        // Care breakdown
                        careBreakdown

                        // Watering frequency chart
                        wateringFrequencyChart

                        // Export
                        if revenueCatManager.isPremium {
                            exportButton
                        } else {
                            premiumExportNudge
                        }

                        Spacer(minLength: 40)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                }
            }
            .navigationTitle("\(plant.name) Analytics")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .font(.system(.body, design: .rounded))
                        .fontWeight(.semibold)
                        .foregroundColor(AppColors.limeGreen)
                }
            }
            .fullScreenCover(isPresented: $showPaywall) {
                PaywallView()
            }
            .sheet(isPresented: $showExport) {
                if !exportCSV.isEmpty {
                    ShareSheetView(text: exportCSV)
                }
            }
        }
    }

    // MARK: - Plant Header

    private var plantHeader: some View {
        HStack(spacing: 14) {
            if let img = plant.photoImage {
                img
                    .resizable()
                    .scaledToFill()
                    .frame(width: 56, height: 56)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(AppColors.limeGreen, lineWidth: 2))
            } else {
                Circle()
                    .fill(AppColors.forestGreen.opacity(0.3))
                    .frame(width: 56, height: 56)
                    .overlay {
                        Image(systemName: "leaf.fill")
                            .foregroundColor(.white.opacity(0.6))
                    }
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(plant.name)
                    .font(.system(.headline, design: .rounded))
                    .fontWeight(.bold)
                    .foregroundColor(AppColors.textPrimary)
                if let species = plant.species {
                    Text(species)
                        .font(.system(.caption, design: .rounded))
                        .foregroundColor(AppColors.textSecondary)
                }
                Text("Tracked for \(daysSinceCreated) days")
                    .font(.system(.caption2, design: .rounded))
                    .foregroundColor(AppColors.textSecondary.opacity(0.7))
            }
            Spacer()
        }
    }

    // MARK: - Stats Row

    private var statsRow: some View {
        HStack(spacing: 0) {
            miniStat(value: "\(plant.wateringStreak)", label: "Streak", icon: "flame.fill", color: .orange)
            miniDivider
            miniStat(value: "\(wateringCount)", label: "Waterings", icon: "drop.fill", color: .blue)
            miniDivider
            miniStat(value: "\(plant.healthEntries.count)", label: "Health Checks", icon: "heart.fill", color: .pink)
            miniDivider
            miniStat(value: avgWateringFrequency, label: "Avg Frequency", icon: "clock.fill", color: AppColors.limeGreen)
        }
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(
                    .ultraThinMaterial
                        .shadow(.inner(color: .white.opacity(0.04), radius: 1, y: 1))
                )
                .environment(\.colorScheme, .dark)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white.opacity(0.06), lineWidth: 1)
        )
    }

    private func miniStat(value: String, label: String, icon: String, color: Color) -> some View {
        VStack(spacing: 4) {
            HStack(spacing: 3) {
                Image(systemName: icon)
                    .font(.system(size: 10))
                    .foregroundColor(color)
                Text(value)
                    .font(.system(.subheadline, design: .rounded))
                    .fontWeight(.bold)
                    .foregroundColor(AppColors.textPrimary)
            }
            Text(label)
                .font(.system(size: 9, weight: .medium, design: .rounded))
                .foregroundColor(AppColors.textSecondary)
        }
        .frame(maxWidth: .infinity)
    }

    private var miniDivider: some View {
        Rectangle()
            .fill(Color.white.opacity(0.08))
            .frame(width: 1, height: 32)
    }

    // MARK: - Health Trend Chart

    private var healthTrendChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Health Trend", systemImage: "heart.text.clipboard")
                .font(.system(.subheadline, design: .rounded))
                .fontWeight(.semibold)
                .foregroundColor(AppColors.textPrimary)

            if sortedHealthEntries.count >= 2 {
                let data = healthChartData
                if revenueCatManager.isPremium || data.count <= 5 {
                    Chart(data, id: \.date) { entry in
                        LineMark(
                            x: .value("Date", entry.date),
                            y: .value("Score", entry.score)
                        )
                        .foregroundStyle(
                            LinearGradient(
                                colors: [AppColors.limeGreen, .green],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .lineStyle(StrokeStyle(lineWidth: 2.5, lineCap: .round))

                        PointMark(
                            x: .value("Date", entry.date),
                            y: .value("Score", entry.score)
                        )
                        .foregroundStyle(AppColors.limeGreen)
                        .symbolSize(30)

                        AreaMark(
                            x: .value("Date", entry.date),
                            y: .value("Score", entry.score)
                        )
                        .foregroundStyle(
                            LinearGradient(
                                colors: [AppColors.limeGreen.opacity(0.2), .clear],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                    }
                    .chartYScale(domain: 0...3)
                    .chartYAxis {
                        AxisMarks(values: [0, 1, 2, 3]) { value in
                            AxisGridLine(stroke: StrokeStyle(lineWidth: 0.3))
                                .foregroundStyle(Color.white.opacity(0.1))
                            AxisValueLabel {
                                let labels = ["😟", "❓", "😐", "😊"]
                                Text(labels[value.as(Int.self) ?? 0])
                                    .font(.system(size: 10))
                            }
                        }
                    }
                    .chartXAxis {
                        AxisMarks { _ in
                            AxisGridLine(stroke: StrokeStyle(lineWidth: 0.3))
                                .foregroundStyle(Color.white.opacity(0.1))
                            AxisValueLabel(format: .dateTime.month(.abbreviated).day())
                                .foregroundStyle(AppColors.textSecondary)
                        }
                    }
                    .frame(height: 160)
                } else {
                    lockedChartPlaceholder(height: 160)
                }
            } else {
                HStack {
                    Spacer()
                    VStack(spacing: 6) {
                        Image(systemName: "chart.line.uptrend.xyaxis")
                            .font(.system(size: 24, weight: .ultraLight))
                            .foregroundColor(AppColors.textSecondary.opacity(0.4))
                        Text("Need 2+ health checks for trend")
                            .font(.system(.caption2, design: .rounded))
                            .foregroundColor(AppColors.textSecondary)
                    }
                    Spacer()
                }
                .frame(height: 100)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(
                    .ultraThinMaterial
                        .shadow(.inner(color: .white.opacity(0.04), radius: 1, y: 1))
                )
                .environment(\.colorScheme, .dark)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.white.opacity(0.06), lineWidth: 1)
        )
    }

    private var healthChartData: [HealthChartPoint] {
        sortedHealthEntries.map { entry in
            let score: Int
            switch entry.status {
            case "healthy": score = 3
            case "okay": score = 2
            case "struggling": score = 0
            default: score = 1
            }
            return HealthChartPoint(date: entry.date, score: score)
        }
    }

    // MARK: - Care Breakdown

    private var careBreakdown: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Care Breakdown", systemImage: "chart.pie.fill")
                .font(.system(.subheadline, design: .rounded))
                .fontWeight(.semibold)
                .foregroundColor(AppColors.textPrimary)

            let types: [(type: CareType, count: Int)] = CareType.allCases.map { type in
                (type, plant.careLogs.filter { $0.careType == type.rawValue }.count)
            }.filter { $0.count > 0 }

            if types.isEmpty {
                HStack {
                    Spacer()
                    Text("No care activities recorded yet")
                        .font(.system(.caption, design: .rounded))
                        .foregroundColor(AppColors.textSecondary)
                    Spacer()
                }
                .padding(.vertical, 16)
            } else {
                let total = types.reduce(0) { $0 + $1.count }
                ForEach(types, id: \.type) { item in
                    HStack(spacing: 12) {
                        Image(systemName: item.type.iconName)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(item.type.color)
                            .frame(width: 20)

                        Text(item.type.label)
                            .font(.system(.caption, design: .rounded))
                            .fontWeight(.medium)
                            .foregroundColor(AppColors.textPrimary)

                        Spacer()

                        Text("\(item.count)")
                            .font(.system(.caption, design: .rounded))
                            .fontWeight(.bold)
                            .foregroundColor(AppColors.textPrimary)

                        // Mini progress bar
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(Color.white.opacity(0.08))
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(item.type.color)
                                    .frame(width: geo.size.width * CGFloat(item.count) / CGFloat(total))
                            }
                        }
                        .frame(width: 60, height: 6)
                    }
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(
                    .ultraThinMaterial
                        .shadow(.inner(color: .white.opacity(0.04), radius: 1, y: 1))
                )
                .environment(\.colorScheme, .dark)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.white.opacity(0.06), lineWidth: 1)
        )
    }

    // MARK: - Watering Frequency Chart

    private var wateringFrequencyChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Watering History", systemImage: "drop.fill")
                .font(.system(.subheadline, design: .rounded))
                .fontWeight(.semibold)
                .foregroundColor(AppColors.textPrimary)

            let data = wateringChartData
            if data.isEmpty {
                HStack {
                    Spacer()
                    Text("Water this plant to see the chart")
                        .font(.system(.caption2, design: .rounded))
                        .foregroundColor(AppColors.textSecondary)
                    Spacer()
                }
                .frame(height: 80)
            } else if revenueCatManager.isPremium || data.count <= 10 {
                Chart(data, id: \.date) { entry in
                    BarMark(
                        x: .value("Day", entry.date, unit: .day),
                        y: .value("Count", entry.count)
                    )
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.blue.opacity(0.8), .cyan],
                            startPoint: .bottom,
                            endPoint: .top
                        )
                    )
                    .cornerRadius(2)
                }
                .chartXAxis {
                    AxisMarks { _ in
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
                .frame(height: 120)
            } else {
                lockedChartPlaceholder(height: 120)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(
                    .ultraThinMaterial
                        .shadow(.inner(color: .white.opacity(0.04), radius: 1, y: 1))
                )
                .environment(\.colorScheme, .dark)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.white.opacity(0.06), lineWidth: 1)
        )
    }

    private var wateringChartData: [ChartDataPoint] {
        let calendar = Calendar.current
        let thirtyDaysAgo = calendar.date(byAdding: .day, value: -30, to: Date.now)!
        let waterLogs = plant.careLogs.filter { $0.careType == "water" && $0.logDate >= thirtyDaysAgo }

        var grouped: [Date: Int] = [:]
        for i in 0..<30 {
            let day = calendar.startOfDay(for: calendar.date(byAdding: .day, value: -i, to: Date.now)!)
            grouped[day] = 0
        }
        for log in waterLogs {
            let day = calendar.startOfDay(for: log.logDate)
            grouped[day, default: 0] += 1
        }
        return grouped.map { ChartDataPoint(date: $0.key, count: $0.value) }.sorted { $0.date < $1.date }
    }

    // MARK: - Export

    private var exportButton: some View {
        Button {
            exportCSV = generatePlantCSV()
            showExport = true
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "square.and.arrow.up")
                    .font(.system(size: 14, weight: .semibold))
                Text("Export \(plant.name) Data")
                    .font(.system(.subheadline, design: .rounded))
                    .fontWeight(.bold)
            }
            .foregroundColor(.black)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                LinearGradient(
                    colors: [AppColors.limeGreen, AppColors.forestGreen],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(12)
        }
    }

    private var premiumExportNudge: some View {
        Button {
            showPaywall = true
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "lock.fill")
                    .font(.system(size: 13))
                Text("Export Plant Data")
                    .font(.system(.subheadline, design: .rounded))
                    .fontWeight(.medium)
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
        }
    }

    // MARK: - Locked Chart

    private func lockedChartPlaceholder(height: CGFloat) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.white.opacity(0.03))
                .frame(height: height)
            VStack(spacing: 8) {
                Image(systemName: "lock.fill")
                    .foregroundColor(AppColors.textSecondary)
                Text("Premium feature")
                    .font(.system(.caption2, design: .rounded))
                    .foregroundColor(AppColors.textSecondary)
            }
        }
        .onTapGesture { showPaywall = true }
    }

    // MARK: - CSV

    private func generatePlantCSV() -> String {
        var csv = "=== \(plant.name) — Plant Data Export ===\n"
        csv += "Generated: \(Date.now.formatted())\n\n"
        csv += "Name,\(plant.name)\n"
        csv += "Species,\(plant.species ?? "")\n"
        csv += "Room,\(plant.room ?? "")\n"
        csv += "Watering Interval,\(plant.wateringIntervalDays) days\n"
        csv += "Streak,\(plant.wateringStreak)\n"
        csv += "Health,\(plant.currentHealth.displayName)\n\n"

        csv += "--- Care Logs ---\nDate,Type,Notes\n"
        for log in sortedCareLogs {
            csv += "\(log.logDate.formatted(date: .abbreviated, time: .shortened)),\(log.careType),\"\(log.notes ?? "")\"\n"
        }

        csv += "\n--- Health Entries ---\nDate,Status,Notes\n"
        for entry in sortedHealthEntries {
            csv += "\(entry.date.formatted(date: .abbreviated, time: .shortened)),\(entry.status),\"\(entry.notes ?? "")\"\n"
        }

        csv += "\n--- Diagnoses ---\nDate,Healthy,Disease,Severity\n"
        for diag in plant.diagnosisEntries.sorted(by: { $0.diagnosisDate > $1.diagnosisDate }) {
            csv += "\(diag.diagnosisDate.formatted(date: .abbreviated, time: .shortened)),\(diag.isHealthy),\"\(diag.diseaseName ?? "")\",\(diag.severity)\n"
        }

        return csv
    }
}

// MARK: - Health Chart Point

struct HealthChartPoint {
    let date: Date
    let score: Int
}
