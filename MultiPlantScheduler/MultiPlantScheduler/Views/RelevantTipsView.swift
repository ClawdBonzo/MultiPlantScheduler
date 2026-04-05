import SwiftUI
import SwiftData

/// Embeddable section showing 2-3 relevant community tips based on context
/// Used in PlantDetailView and DiagnosisResultView
struct RelevantTipsView: View {
    let plantName: String?
    let diseaseName: String?
    let contextLabel: String  // e.g. "Other Monstera owners recommend" or "Users who dealt with this"

    @Query(sort: \CommunityTip.helpfulCount, order: .reverse) private var allTips: [CommunityTip]

    init(plantName: String? = nil, diseaseName: String? = nil, contextLabel: String = "Community Tips") {
        self.plantName = plantName
        self.diseaseName = diseaseName
        self.contextLabel = contextLabel
    }

    var relevantTips: [CommunityTip] {
        var scored: [(tip: CommunityTip, score: Int)] = []

        for tip in allTips {
            var score = 0

            // Match by disease name (highest priority)
            if let disease = diseaseName?.lowercased(), !disease.isEmpty {
                if let related = tip.relatedDisease?.lowercased(), related.contains(disease) || disease.contains(related) {
                    score += 50
                }
                if tip.tipTitle.lowercased().contains(disease) || tip.tipDescription.lowercased().contains(disease) {
                    score += 30
                }
                // Category match for disease/pest context
                if tip.category == "disease" || tip.category == "pest" {
                    score += 10
                }
            }

            // Match by plant name
            if let plant = plantName?.lowercased(), !plant.isEmpty {
                let tipPlant = tip.plantName.lowercased()
                if tipPlant == plant || tipPlant.contains(plant) || plant.contains(tipPlant) {
                    score += 25
                }
                // "All Plants" tips are always somewhat relevant
                if tipPlant == "all plants" {
                    score += 8
                }
            }

            // Boost highly-voted tips
            if tip.helpfulCount > 1000 {
                score += 5
            }

            if score > 0 {
                scored.append((tip, score))
            }
        }

        // Sort by relevance score, take top 3
        let sorted = scored.sorted { $0.score > $1.score }
        return Array(sorted.prefix(3).map(\.tip))
    }

    var socialProofCount: Int {
        relevantTips.reduce(0) { $0 + $1.helpfulCount }
    }

    var body: some View {
        if !relevantTips.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                // Header with social proof
                HStack(spacing: 8) {
                    Image(systemName: "person.2.fill")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(AppColors.limeGreen)

                    Text(contextLabel)
                        .font(.system(.subheadline, design: .rounded))
                        .fontWeight(.semibold)
                        .foregroundColor(AppColors.textPrimary)

                    Spacer()
                }

                // Social proof counter
                if socialProofCount > 0 {
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 10))
                            .foregroundColor(AppColors.limeGreen.opacity(0.7))
                        Text(formatSocialProof(socialProofCount))
                            .font(.system(.caption2, design: .rounded))
                            .foregroundColor(AppColors.textSecondary)
                    }
                    .padding(.top, -6)
                }

                // Compact tip cards
                ForEach(relevantTips) { tip in
                    CompactTipRow(tip: tip)
                }
            }
        }
    }

    private func formatSocialProof(_ count: Int) -> String {
        if count >= 1000 {
            return String(format: "%.1fK users helped with this issue", Double(count) / 1000)
        }
        return "\(count) users helped with this issue"
    }
}

// MARK: - Compact Tip Row (for embedding)

struct CompactTipRow: View {
    @Bindable var tip: CommunityTip
    @Environment(\.modelContext) var modelContext
    @State private var hasVoted = false

    private var isVoted: Bool {
        UserDefaults.standard.bool(forKey: "voted_\(tip.id.uuidString)")
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header
            HStack(spacing: 6) {
                Text(tip.tipCategory.emoji)
                    .font(.system(size: 11))

                Text(tip.plantName)
                    .font(.system(.caption2, design: .rounded))
                    .fontWeight(.bold)
                    .foregroundColor(tip.tipCategory.color)

                Text("·")
                    .foregroundColor(AppColors.textSecondary)

                Text("by \(tip.authorName)")
                    .font(.system(.caption2, design: .rounded))
                    .foregroundColor(AppColors.textSecondary.opacity(0.7))

                Spacer()
            }

            // Title
            Text(tip.tipTitle)
                .font(.system(.caption, design: .rounded))
                .fontWeight(.semibold)
                .foregroundColor(AppColors.textPrimary)
                .lineLimit(1)

            // Description
            Text(tip.tipDescription)
                .font(.system(.caption2, design: .rounded))
                .foregroundColor(AppColors.textPrimary.opacity(0.75))
                .lineLimit(2)
                .lineSpacing(1)

            // Helpful
            HStack {
                Button {
                    toggleVote()
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: (hasVoted || isVoted) ? "hand.thumbsup.fill" : "hand.thumbsup")
                            .font(.system(size: 10))
                        Text("\(tip.helpfulCount)")
                            .font(.system(.caption2, design: .rounded))
                            .fontWeight(.medium)
                    }
                    .foregroundColor((hasVoted || isVoted) ? AppColors.limeGreen : AppColors.textSecondary.opacity(0.6))
                }

                Spacer()
            }
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white.opacity(0.04))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.white.opacity(0.06), lineWidth: 0.5)
                )
        )
        .onAppear { hasVoted = isVoted }
    }

    private func toggleVote() {
        let impact = UIImpactFeedbackGenerator(style: .light)
        impact.impactOccurred()

        if hasVoted {
            tip.helpfulCount = max(0, tip.helpfulCount - 1)
            hasVoted = false
            UserDefaults.standard.set(false, forKey: "voted_\(tip.id.uuidString)")
        } else {
            tip.helpfulCount += 1
            hasVoted = true
            UserDefaults.standard.set(true, forKey: "voted_\(tip.id.uuidString)")
        }
        try? modelContext.save()
    }
}
