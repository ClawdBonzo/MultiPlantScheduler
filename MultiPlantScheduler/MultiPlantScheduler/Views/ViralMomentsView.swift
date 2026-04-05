import SwiftUI

/// "Viral Moments" section for Community tab — showcases the best shared results
struct ViralMomentsSection: View {
    @State private var animateEntrance = false

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Header
            PremiumSectionHeader(
                icon: "flame.fill",
                iconColor: .orange,
                title: "Viral Moments",
                trailing: "Trending",
                trailingColor: .orange
            )

            // Horizontal scroll of viral cards
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(Array(ViralMoment.seeds.enumerated()), id: \.element.id) { index, moment in
                        ViralMomentCard(moment: moment)
                            .opacity(animateEntrance ? 1 : 0)
                            .offset(x: animateEntrance ? 0 : 30)
                            .animation(
                                .spring(response: 0.5, dampingFraction: 0.8)
                                    .delay(Double(index) * 0.08),
                                value: animateEntrance
                            )
                    }
                }
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                animateEntrance = true
            }
        }
    }
}

// MARK: - Viral Moment Data

struct ViralMoment: Identifiable {
    let id = UUID()
    let username: String
    let plantName: String
    let caption: String
    let emoji: String
    let likes: Int
    let shares: Int
    let comments: Int
    let category: String     // "diagnosis", "streak", "showcase", "recovery"
    let gradientColors: [Color]

    static var seeds: [ViralMoment] {
        [
            ViralMoment(
                username: "@plant_mom_jessica",
                plantName: "Monstera",
                caption: "AI caught root rot before I even noticed!! Saved my 3yr old Monstera 😭🌿",
                emoji: "🦠",
                likes: 24_700,
                shares: 3_200,
                comments: 891,
                category: "diagnosis",
                gradientColors: [.purple, .pink]
            ),
            ViralMoment(
                username: "@urban.jungle.tom",
                plantName: "Fiddle Leaf Fig",
                caption: "90 DAY STREAK 🔥 This app literally taught me how to not kill plants",
                emoji: "🔥",
                likes: 18_300,
                shares: 2_100,
                comments: 643,
                category: "streak",
                gradientColors: [.orange, .red]
            ),
            ViralMoment(
                username: "@succulent_sarah",
                plantName: "Snake Plant",
                caption: "POV: the app tells you your 'dead' plant is actually fine and you've been overwatering 💀",
                emoji: "💀",
                likes: 31_200,
                shares: 5_400,
                comments: 1_247,
                category: "diagnosis",
                gradientColors: [.green, .cyan]
            ),
            ViralMoment(
                username: "@green.thumb.mike",
                plantName: "Calathea",
                caption: "Spider mites → identified → treated → THRIVING in 3 weeks. This app is unreal.",
                emoji: "🐛",
                likes: 15_800,
                shares: 1_900,
                comments: 412,
                category: "recovery",
                gradientColors: [.blue, .purple]
            ),
            ViralMoment(
                username: "@botanical.beth",
                plantName: "All Plants",
                caption: "My entire collection in one app with AI health checks?? WHERE HAS THIS BEEN 🤯",
                emoji: "🤯",
                likes: 42_100,
                shares: 7_800,
                comments: 2_034,
                category: "showcase",
                gradientColors: [Color(red: 0.2, green: 0.8, blue: 0.2), .yellow]
            ),
        ]
    }
}

// MARK: - Viral Moment Card

struct ViralMomentCard: View {
    let moment: ViralMoment

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Header
            HStack(spacing: 6) {
                // Fake avatar
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: moment.gradientColors,
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 28, height: 28)
                    Text(moment.emoji)
                        .font(.system(size: 13))
                }

                VStack(alignment: .leading, spacing: 0) {
                    Text(moment.username)
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .foregroundColor(AppColors.textPrimary)
                    Text(moment.plantName)
                        .font(.system(size: 9, weight: .medium, design: .rounded))
                        .foregroundColor(AppColors.limeGreen)
                }
            }

            // Caption
            Text(moment.caption)
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundColor(AppColors.textPrimary.opacity(0.9))
                .lineLimit(3)
                .lineSpacing(2)

            Spacer()

            // Engagement stats
            HStack(spacing: 12) {
                engagementStat(icon: "heart.fill", count: moment.likes, color: .red)
                engagementStat(icon: "arrow.2.squarepath", count: moment.shares, color: AppColors.limeGreen)
                engagementStat(icon: "bubble.fill", count: moment.comments, color: .blue)
            }
        }
        .padding(12)
        .frame(width: 220, height: 160)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    .ultraThinMaterial
                        .shadow(.inner(color: .white.opacity(0.06), radius: 1, x: 0, y: 1))
                        .shadow(.inner(color: .black.opacity(0.15), radius: 2, x: 0, y: -1))
                )
                .environment(\.colorScheme, .dark)
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    LinearGradient(
                        colors: [moment.gradientColors.first!.opacity(0.25), Color.white.opacity(0.04)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 0.8
                )
        )
        .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
    }

    private func engagementStat(icon: String, count: Int, color: Color) -> some View {
        HStack(spacing: 3) {
            Image(systemName: icon)
                .font(.system(size: 9))
                .foregroundColor(color.opacity(0.8))
            Text(formatCompact(count))
                .font(.system(size: 9, weight: .semibold, design: .rounded))
                .foregroundColor(AppColors.textSecondary)
        }
    }

    private func formatCompact(_ n: Int) -> String {
        if n >= 1000 {
            return String(format: "%.1fK", Double(n) / 1000)
        }
        return "\(n)"
    }
}
