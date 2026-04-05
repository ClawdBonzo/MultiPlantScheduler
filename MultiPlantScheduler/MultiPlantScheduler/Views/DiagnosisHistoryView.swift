import SwiftUI
import SwiftData

/// Shows all past diagnosis entries
struct DiagnosisHistoryView: View {
    @Query(sort: \DiagnosisEntry.diagnosisDate, order: .reverse) var diagnoses: [DiagnosisEntry]
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss

    @State private var filterCategory: DiagnosisCategory?

    var filteredDiagnoses: [DiagnosisEntry] {
        guard let filter = filterCategory else { return diagnoses }
        if filter == .healthy {
            return diagnoses.filter { $0.isHealthy }
        }
        return diagnoses.filter { $0.category == filter.rawValue }
    }

    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()

            if diagnoses.isEmpty {
                emptyState
            } else {
                VStack(spacing: 0) {
                    // Filter chips
                    filterBar
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)

                    // Stats summary
                    statsBar
                        .padding(.horizontal, 16)
                        .padding(.bottom, 12)

                    // Diagnosis list
                    ScrollView {
                        LazyVStack(spacing: 10) {
                            ForEach(filteredDiagnoses) { entry in
                                DiagnosisHistoryRow(entry: entry)
                                    .contextMenu {
                                        Button(role: .destructive) {
                                            modelContext.delete(entry)
                                            try? modelContext.save()
                                        } label: {
                                            Label("Delete", systemImage: "trash")
                                        }
                                    }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 40)
                    }
                }
            }
        }
        .navigationTitle("Diagnosis History")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Done") { dismiss() }
            }
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "microbe.fill")
                .font(.system(size: 48, weight: .ultraLight))
                .foregroundColor(AppColors.textSecondary.opacity(0.5))

            Text("No Diagnoses Yet")
                .font(.system(.title3, design: .rounded))
                .fontWeight(.bold)
                .foregroundColor(AppColors.textSecondary)

            Text("Use the Diagnose tab to analyze\nyour plants for diseases and pests")
                .font(.system(.subheadline, design: .rounded))
                .foregroundColor(AppColors.textSecondary.opacity(0.7))
                .multilineTextAlignment(.center)
        }
    }

    // MARK: - Filter Bar

    private var filterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                FilterChip(label: "All", isSelected: filterCategory == nil) {
                    filterCategory = nil
                }

                ForEach([DiagnosisCategory.healthy, .disease, .pest, .abiotic], id: \.self) { cat in
                    FilterChip(
                        label: "\(cat.emoji) \(cat.displayName)",
                        isSelected: filterCategory == cat
                    ) {
                        filterCategory = (filterCategory == cat) ? nil : cat
                    }
                }
            }
        }
    }

    // MARK: - Stats Bar

    private var statsBar: some View {
        HStack(spacing: 12) {
            StatPill(
                value: "\(diagnoses.count)",
                label: "Total",
                color: AppColors.limeGreen
            )

            StatPill(
                value: "\(diagnoses.filter { $0.isHealthy }.count)",
                label: "Healthy",
                color: AppColors.forestGreen
            )

            StatPill(
                value: "\(diagnoses.filter { !$0.isHealthy }.count)",
                label: "Issues",
                color: .red
            )

            Spacer()
        }
    }
}

// MARK: - Filter Chip

struct FilterChip: View {
    let label: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.system(.caption, design: .rounded))
                .fontWeight(.semibold)
                .foregroundColor(isSelected ? .black : AppColors.textSecondary)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? AppColors.limeGreen : Color.white.opacity(0.08))
                .cornerRadius(16)
        }
    }
}

// MARK: - Stat Pill

struct StatPill: View {
    let value: String
    let label: String
    let color: Color

    var body: some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.system(.headline, design: .rounded))
                .fontWeight(.bold)
                .foregroundColor(color)
            Text(label)
                .font(.system(.caption2, design: .rounded))
                .foregroundColor(AppColors.textSecondary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(color.opacity(0.1))
        .cornerRadius(8)
    }
}

// MARK: - History Row

struct DiagnosisHistoryRow: View {
    let entry: DiagnosisEntry

    var body: some View {
        HStack(spacing: 12) {
            // Photo thumbnail
            if let img = entry.photoImage {
                img
                    .resizable()
                    .scaledToFill()
                    .frame(width: 56, height: 56)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(
                                entry.isHealthy ? AppColors.forestGreen.opacity(0.5) : entry.severityLevel.color.opacity(0.5),
                                lineWidth: 1
                            )
                    )
            } else {
                RoundedRectangle(cornerRadius: 10)
                    .fill(entry.diagnosisCategory.color.opacity(0.15))
                    .frame(width: 56, height: 56)
                    .overlay {
                        Image(systemName: entry.diagnosisCategory.iconName)
                            .font(.system(size: 22))
                            .foregroundColor(entry.diagnosisCategory.color)
                    }
            }

            // Details
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(entry.isHealthy ? "Healthy" : (entry.diseaseName ?? "Unknown"))
                        .font(.system(.subheadline, design: .rounded))
                        .fontWeight(.semibold)
                        .foregroundColor(AppColors.textPrimary)
                        .lineLimit(1)
                }

                HStack(spacing: 6) {
                    // Category
                    HStack(spacing: 3) {
                        Text(entry.diagnosisCategory.emoji)
                            .font(.system(size: 10))
                        Text(entry.diagnosisCategory.displayName)
                            .font(.system(.caption2, design: .rounded))
                            .foregroundColor(entry.diagnosisCategory.color)
                    }

                    if !entry.isHealthy {
                        // Severity
                        Text(entry.severityLevel.displayName)
                            .font(.system(.caption2, design: .rounded))
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 5)
                            .padding(.vertical, 1)
                            .background(entry.severityLevel.color)
                            .cornerRadius(3)

                        // Confidence
                        Text("\(Int(entry.confidence * 100))%")
                            .font(.system(.caption2, design: .rounded))
                            .foregroundColor(AppColors.textSecondary)
                    }
                }

                HStack(spacing: 4) {
                    if let plant = entry.plant {
                        Image(systemName: "leaf.fill")
                            .font(.system(size: 9))
                            .foregroundColor(AppColors.limeGreen)
                        Text(plant.name)
                            .font(.system(.caption2, design: .rounded))
                            .foregroundColor(AppColors.limeGreen)
                        Text("·")
                            .foregroundColor(AppColors.textSecondary)
                    }

                    Text(entry.diagnosisDate, format: .dateTime.month(.abbreviated).day().year())
                        .font(.system(.caption2, design: .rounded))
                        .foregroundColor(AppColors.textSecondary)
                }
            }

            Spacer()

            // Status indicator
            Image(systemName: entry.isHealthy ? "checkmark.circle.fill" : entry.severityLevel.iconName)
                .font(.system(size: 20))
                .foregroundColor(entry.isHealthy ? AppColors.forestGreen : entry.severityLevel.color)
        }
        .padding(12)
        .background(Color.white.opacity(0.05))
        .cornerRadius(12)
    }
}
