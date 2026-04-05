import SwiftUI
import SwiftData

/// A single community tip card with premium glassmorphism styling
struct CommunityTipCard: View {
    @Bindable var tip: CommunityTip
    @Environment(\.modelContext) var modelContext
    @State private var hasVoted = false
    @State private var voteScale: CGFloat = 1.0

    private var isVoted: Bool {
        UserDefaults.standard.bool(forKey: "voted_\(tip.id.uuidString)")
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header: plant name + category badge
            HStack(spacing: 8) {
                // Plant avatar
                ZStack {
                    Circle()
                        .fill(tip.tipCategory.color.opacity(0.12))
                        .frame(width: 36, height: 36)
                    Image(systemName: tip.tipCategory.iconName)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(tip.tipCategory.color)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(tip.plantName)
                        .font(.system(.caption, design: .rounded))
                        .fontWeight(.semibold)
                        .foregroundColor(tip.tipCategory.color)

                    Text("by \(tip.authorName)")
                        .font(.system(.caption2, design: .rounded))
                        .foregroundColor(AppColors.textSecondary.opacity(0.7))
                }

                Spacer()

                // Category pill
                Text("\(tip.tipCategory.emoji) \(tip.tipCategory.displayName)")
                    .font(.system(.caption2, design: .rounded))
                    .fontWeight(.bold)
                    .foregroundColor(tip.tipCategory.color)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(tip.tipCategory.color.opacity(0.10))
                    .cornerRadius(6)
            }

            // Title
            Text(tip.tipTitle)
                .font(.system(.subheadline, design: .rounded))
                .fontWeight(.bold)
                .foregroundColor(AppColors.textPrimary)
                .lineLimit(2)

            // Description
            Text(tip.tipDescription)
                .font(.system(.caption, design: .rounded))
                .foregroundColor(AppColors.textPrimary.opacity(0.8))
                .lineLimit(4)
                .lineSpacing(2)

            // Optional photo
            if let img = tip.photoImage {
                img
                    .resizable()
                    .scaledToFill()
                    .frame(height: 120)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.white.opacity(0.06), lineWidth: 0.5)
                    )
            }

            // Footer: helpful button + social proof
            HStack(spacing: 16) {
                // Helpful button
                Button {
                    toggleVote()
                } label: {
                    HStack(spacing: 5) {
                        Image(systemName: (hasVoted || isVoted) ? "hand.thumbsup.fill" : "hand.thumbsup")
                            .font(.system(size: 13, weight: .medium))
                        Text("Helpful")
                            .font(.system(.caption2, design: .rounded))
                            .fontWeight(.semibold)
                        Text("(\(tip.helpfulCount))")
                            .font(.system(.caption2, design: .rounded))
                            .fontWeight(.medium)
                    }
                    .foregroundColor((hasVoted || isVoted) ? AppColors.emerald : AppColors.textSecondary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill((hasVoted || isVoted) ? AppColors.emerald.opacity(0.12) : Color.white.opacity(0.04))
                    )
                    .overlay(
                        Capsule()
                            .stroke((hasVoted || isVoted) ? AppColors.emerald.opacity(0.2) : Color.clear, lineWidth: 0.5)
                    )
                }
                .scaleEffect(voteScale)
                .disabled(isVoted && !hasVoted)

                Spacer()

                // Social proof
                HStack(spacing: 4) {
                    Image(systemName: "person.2.fill")
                        .font(.system(size: 10))
                        .foregroundColor(AppColors.textSecondary.opacity(0.5))
                    Text(socialProofText)
                        .font(.system(.caption2, design: .rounded))
                        .foregroundColor(AppColors.textSecondary.opacity(0.6))
                }
            }
        }
        .premiumGlass(cornerRadius: 16, strokeOpacity: 0.10, padding: 14)
        .onAppear {
            hasVoted = isVoted
        }
    }

    // MARK: - Vote

    private func toggleVote() {
        let impact = UIImpactFeedbackGenerator(style: .light)
        impact.impactOccurred()

        withAnimation(SpringPreset.bouncy) {
            voteScale = 1.2
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            withAnimation(SpringPreset.snappy) {
                voteScale = 1.0
            }
        }

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

    // MARK: - Social Proof Text

    private var socialProofText: String {
        let count = tip.helpfulCount
        if count > 1000 {
            return String(format: "%.1fK users found helpful", Double(count) / 1000)
        } else if count > 0 {
            return "\(count) users found helpful"
        }
        return "Be the first to help!"
    }
}
