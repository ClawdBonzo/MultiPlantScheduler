import SwiftUI
import SwiftData

/// Shows the results of a disease/pest diagnosis with severity badges and treatment plans
struct DiagnosisResultView: View {
    let result: DiagnosisService.DiagnosisResult
    let imageData: Data?
    let plant: Plant?
    let onDismiss: () -> Void

    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        // Health status hero
                        healthHero

                        // Photo preview
                        if let imageData = imageData,
                           let uiImage = UIImage(data: imageData) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                                .frame(height: 180)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(
                                            result.isHealthy ? AppColors.forestGreen : Color.red.opacity(0.5),
                                            lineWidth: 2
                                        )
                                )
                        }

                        // Linked plant
                        if let plant = plant {
                            HStack(spacing: 10) {
                                if let img = plant.photoImage {
                                    img
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 32, height: 32)
                                        .clipShape(Circle())
                                }
                                Text(plant.name)
                                    .font(.system(.subheadline, design: .rounded))
                                    .fontWeight(.medium)
                                    .foregroundColor(AppColors.textPrimary)
                                Spacer()
                            }
                            .padding(10)
                            .background(Color.white.opacity(0.05))
                            .cornerRadius(8)
                        }

                        if result.isHealthy {
                            healthyResultSection
                        } else {
                            // Disease/pest cards
                            ForEach(Array(result.diseases.enumerated()), id: \.offset) { index, issue in
                                issueCard(issue: issue, rank: index + 1)
                            }
                        }

                        // Community tips
                        if !result.isHealthy, let topIssue = result.diseases.first {
                            RelevantTipsView(
                                plantName: plant?.species ?? plant?.name,
                                diseaseName: topIssue.name,
                                contextLabel: "Other users dealt with this — here's what worked"
                            )
                        } else if result.isHealthy {
                            RelevantTipsView(
                                plantName: plant?.species ?? plant?.name,
                                diseaseName: nil,
                                contextLabel: "Tips to keep your plant thriving"
                            )
                        }

                        // Share to Stories
                        ShareStoryButton(
                            plantName: plant?.name ?? "My Plant",
                            subtitle: result.isHealthy
                                ? "✅ Healthy — \(Int(result.healthProbability * 100))% Health Score"
                                : "Diagnosed: \(result.diseases.first?.name ?? "Issue detected")",
                            accentText: result.isHealthy
                                ? nil
                                : "AI identified in seconds",
                            plantImage: imageData.flatMap { UIImage(data: $0) },
                            cardStyle: result.isHealthy
                                ? .healthScore(percent: Int(result.healthProbability * 100))
                                : .diagnosis(isHealthy: false, diseaseName: result.diseases.first?.name)
                        )

                        // Done button
                        Button {
                            dismiss()
                            onDismiss()
                        } label: {
                            Text("Done")
                                .font(.system(.headline, design: .rounded))
                                .fontWeight(.bold)
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(AppColors.limeGreen)
                                .cornerRadius(12)
                        }
                        .padding(.top, 8)

                        Spacer(minLength: 40)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                }
            }
            .navigationTitle("Diagnosis Results")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                        onDismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(AppColors.textSecondary)
                    }
                }
            }
        }
    }

    // MARK: - Health Hero

    private var healthHero: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(
                        result.isHealthy
                            ? AppColors.forestGreen.opacity(0.2)
                            : Color.red.opacity(0.15)
                    )
                    .frame(width: 90, height: 90)

                Image(systemName: result.isHealthy ? "checkmark.shield.fill" : "exclamationmark.triangle.fill")
                    .font(.system(size: 40, weight: .light))
                    .foregroundColor(result.isHealthy ? AppColors.limeGreen : .red)
            }

            VStack(spacing: 6) {
                Text(result.isHealthy ? "Plant Looks Healthy!" : "Issues Detected")
                    .font(.system(.title2, design: .rounded))
                    .fontWeight(.bold)
                    .foregroundColor(AppColors.textPrimary)

                Text(result.isHealthy
                     ? "No diseases or pests detected"
                     : "\(result.diseases.count) potential issue\(result.diseases.count == 1 ? "" : "s") found")
                    .font(.system(.subheadline, design: .rounded))
                    .foregroundColor(AppColors.textSecondary)
            }

            // Health probability bar
            VStack(spacing: 6) {
                HStack {
                    Text("Health Score")
                        .font(.system(.caption, design: .rounded))
                        .foregroundColor(AppColors.textSecondary)
                    Spacer()
                    Text("\(Int(result.healthProbability * 100))%")
                        .font(.system(.caption, design: .rounded))
                        .fontWeight(.bold)
                        .foregroundColor(healthScoreColor)
                }

                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.white.opacity(0.1))
                            .frame(height: 8)

                        RoundedRectangle(cornerRadius: 4)
                            .fill(
                                LinearGradient(
                                    colors: [healthScoreColor.opacity(0.8), healthScoreColor],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: geo.size.width * result.healthProbability, height: 8)
                    }
                }
                .frame(height: 8)
            }
            .padding(.horizontal, 4)
        }
    }

    private var healthScoreColor: Color {
        if result.healthProbability > 0.7 {
            return AppColors.limeGreen
        } else if result.healthProbability > 0.4 {
            return .yellow
        } else {
            return .red
        }
    }

    // MARK: - Healthy Result

    private var healthyResultSection: some View {
        VStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 12) {
                Label("Keep up the good work!", systemImage: "sparkles")
                    .font(.system(.headline, design: .rounded))
                    .foregroundColor(AppColors.limeGreen)

                VStack(alignment: .leading, spacing: 8) {
                    tipRow(icon: "drop.fill", text: "Continue your current watering schedule")
                    tipRow(icon: "sun.max.fill", text: "Ensure adequate light for your plant")
                    tipRow(icon: "leaf.fill", text: "Check leaves regularly for early signs")
                    tipRow(icon: "wind", text: "Maintain good air circulation")
                }
            }
            .padding(16)
            .background(AppColors.forestGreen.opacity(0.1))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(AppColors.forestGreen.opacity(0.3), lineWidth: 1)
            )
        }
    }

    private func tipRow(icon: String, text: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(AppColors.limeGreen)
                .frame(width: 20)
            Text(text)
                .font(.system(.subheadline, design: .rounded))
                .foregroundColor(AppColors.textPrimary)
        }
    }

    // MARK: - Issue Card

    private func issueCard(issue: DiagnosisService.DiagnosisResult.DetectedIssue, rank: Int) -> some View {
        let severity = DiagnosisService.estimateSeverity(
            probability: issue.probability,
            issueCount: result.diseases.count
        )
        let severityLevel = SeverityLevel(rawValue: severity) ?? .moderate
        let category = DiagnosisCategory(rawValue: issue.category) ?? .disease

        return VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack(spacing: 10) {
                // Category icon
                ZStack {
                    Circle()
                        .fill(category.color.opacity(0.2))
                        .frame(width: 40, height: 40)
                    Image(systemName: category.iconName)
                        .font(.system(size: 18))
                        .foregroundColor(category.color)
                }

                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 6) {
                        Text(issue.name)
                            .font(.system(.headline, design: .rounded))
                            .fontWeight(.bold)
                            .foregroundColor(AppColors.textPrimary)
                            .lineLimit(2)
                    }

                    HStack(spacing: 8) {
                        // Category badge
                        Text(category.displayName)
                            .font(.system(.caption2, design: .rounded))
                            .fontWeight(.semibold)
                            .foregroundColor(category.color)

                        // Severity badge
                        Text(severityLevel.displayName)
                            .font(.system(.caption2, design: .rounded))
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(severityLevel.color)
                            .cornerRadius(4)

                        // Confidence
                        Text("\(Int(issue.probability * 100))% match")
                            .font(.system(.caption2, design: .rounded))
                            .foregroundColor(AppColors.textSecondary)
                    }
                }

                Spacer()
            }

            // Scientific name
            if let scientific = issue.scientificName {
                Text(scientific)
                    .font(.system(.caption, design: .rounded))
                    .italic()
                    .foregroundColor(AppColors.textSecondary)
            }

            // Description
            if let desc = issue.description {
                Text(desc)
                    .font(.system(.subheadline, design: .rounded))
                    .foregroundColor(AppColors.textPrimary.opacity(0.85))
                    .lineLimit(4)
            }

            // Treatment section
            if let treatment = issue.treatment {
                Divider()
                    .background(Color.white.opacity(0.1))

                VStack(alignment: .leading, spacing: 12) {
                    // Biological treatment
                    if !treatment.biological.isEmpty {
                        treatmentSection(
                            title: "Natural Treatment",
                            icon: "leaf.arrow.triangle.circlepath",
                            color: AppColors.forestGreen,
                            items: treatment.biological
                        )
                    }

                    // Chemical treatment
                    if !treatment.chemical.isEmpty {
                        treatmentSection(
                            title: "Chemical Treatment",
                            icon: "flask.fill",
                            color: .purple,
                            items: treatment.chemical
                        )
                    }

                    // Prevention
                    if !treatment.prevention.isEmpty {
                        treatmentSection(
                            title: "Prevention",
                            icon: "shield.checkered",
                            color: .blue,
                            items: treatment.prevention
                        )
                    }
                }
            }
        }
        .padding(16)
        .background(Color.white.opacity(0.05))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(severityLevel.color.opacity(0.3), lineWidth: 1)
        )
    }

    private func treatmentSection(title: String, icon: String, color: Color, items: [String]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(title, systemImage: icon)
                .font(.system(.subheadline, design: .rounded))
                .fontWeight(.semibold)
                .foregroundColor(color)

            ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                HStack(alignment: .top, spacing: 8) {
                    Text("\(index + 1).")
                        .font(.system(.caption, design: .rounded))
                        .fontWeight(.bold)
                        .foregroundColor(color.opacity(0.7))
                        .frame(width: 16, alignment: .trailing)

                    Text(item)
                        .font(.system(.caption, design: .rounded))
                        .foregroundColor(AppColors.textPrimary.opacity(0.85))
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
    }
}
