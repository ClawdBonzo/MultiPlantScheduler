import SwiftUI
import SwiftData

/// Community tab — feed of user tips, success stories, and social proof
struct CommunityTabView: View {
    @Query(sort: \CommunityTip.helpfulCount, order: .reverse) var allTips: [CommunityTip]
    @Query(sort: \Plant.createdAt) var plants: [Plant]
    @Environment(\.modelContext) var modelContext

    @State private var selectedCategory: TipCategory?
    @State private var showShareTip = false
    @State private var searchText = ""
    @State private var animateEntrance = false

    var filteredTips: [CommunityTip] {
        var tips = allTips
        if let cat = selectedCategory {
            tips = tips.filter { $0.category == cat.rawValue }
        }
        if !searchText.isEmpty {
            let query = searchText.lowercased()
            tips = tips.filter {
                $0.plantName.lowercased().contains(query) ||
                $0.tipTitle.lowercased().contains(query) ||
                $0.tipDescription.lowercased().contains(query)
            }
        }
        return tips
    }

    var totalHelpfulCount: Int {
        allTips.reduce(0) { $0 + $1.helpfulCount }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background.ignoresSafeArea()

                VStack(spacing: 0) {
                    // Social proof banner
                    socialProofBanner
                        .padding(.horizontal, 20)
                        .padding(.top, 8)
                        .padding(.bottom, 12)

                    // Viral Moments
                    ViralMomentsSection()
                        .padding(.horizontal, 20)
                        .padding(.bottom, 14)

                    // Category filter
                    categoryFilter
                        .padding(.bottom, 12)

                    // Search
                    searchBar
                        .padding(.horizontal, 20)
                        .padding(.bottom, 12)

                    if filteredTips.isEmpty {
                        emptyState
                    } else {
                        // Tip feed
                        ScrollView {
                            LazyVStack(spacing: 14) {
                                ForEach(Array(filteredTips.enumerated()), id: \.element.id) { index, tip in
                                    CommunityTipCard(tip: tip)
                                        .opacity(animateEntrance ? 1 : 0)
                                        .offset(y: animateEntrance ? 0 : 20)
                                        .animation(
                                            .spring(response: 0.5, dampingFraction: 0.8)
                                                .delay(Double(min(index, 8)) * 0.05),
                                            value: animateEntrance
                                        )
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.bottom, 100)
                        }
                    }
                }

                // FAB — Share Your Tip
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button {
                            let impact = UIImpactFeedbackGenerator(style: .medium)
                            impact.impactOccurred()
                            showShareTip = true
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "plus.bubble.fill")
                                    .font(.system(size: 16, weight: .bold))
                                Text("Share Tip")
                                    .font(.system(.subheadline, design: .rounded))
                                    .fontWeight(.bold)
                            }
                            .foregroundColor(.black)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 14)
                            .background(
                                Capsule()
                                    .fill(PremiumGradient.button)
                                    .shadow(color: AppColors.emerald.opacity(0.4), radius: 14, y: 6)
                            )
                        }
                        .padding(.trailing, 20)
                        .padding(.bottom, 16)
                    }
                }
            }
            .navigationTitle("Community")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                CommunityTipSeeder.seedIfNeeded(context: modelContext)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    animateEntrance = true
                }
            }
            .sheet(isPresented: $showShareTip) {
                ShareTipView(plants: plants)
            }
        }
    }

    // MARK: - Social Proof Banner

    private var socialProofBanner: some View {
        HStack(spacing: 0) {
            // Users helped stat
            VStack(spacing: 4) {
                HStack(spacing: 4) {
                    Image(systemName: "person.2.fill")
                        .font(.system(size: 12))
                        .foregroundColor(AppColors.emerald)
                    Text(formatNumber(totalHelpfulCount))
                        .font(.system(.headline, design: .rounded))
                        .fontWeight(.bold)
                        .foregroundColor(AppColors.textPrimary)
                }
                Text("users helped")
                    .font(.system(.caption2, design: .rounded))
                    .foregroundColor(AppColors.textSecondary)
            }
            .frame(maxWidth: .infinity)

            // Divider
            Rectangle()
                .fill(Color.white.opacity(0.1))
                .frame(width: 1, height: 32)

            // Tips count
            VStack(spacing: 4) {
                HStack(spacing: 4) {
                    Image(systemName: "lightbulb.fill")
                        .font(.system(size: 12))
                        .foregroundColor(.yellow)
                    Text("\(allTips.count)")
                        .font(.system(.headline, design: .rounded))
                        .fontWeight(.bold)
                        .foregroundColor(AppColors.textPrimary)
                }
                Text("community tips")
                    .font(.system(.caption2, design: .rounded))
                    .foregroundColor(AppColors.textSecondary)
            }
            .frame(maxWidth: .infinity)

            // Divider
            Rectangle()
                .fill(Color.white.opacity(0.1))
                .frame(width: 1, height: 32)

            // Plant species
            VStack(spacing: 4) {
                HStack(spacing: 4) {
                    Image(systemName: "leaf.fill")
                        .font(.system(size: 12))
                        .foregroundColor(AppColors.emerald)
                    let speciesCount = Set(allTips.map { $0.plantName }).count
                    Text("\(speciesCount)")
                        .font(.system(.headline, design: .rounded))
                        .fontWeight(.bold)
                        .foregroundColor(AppColors.textPrimary)
                }
                Text("plant types")
                    .font(.system(.caption2, design: .rounded))
                    .foregroundColor(AppColors.textSecondary)
            }
            .frame(maxWidth: .infinity)
        }
        .premiumGlass(cornerRadius: 14, strokeOpacity: 0.08, padding: 14)
    }

    // MARK: - Category Filter

    private var categoryFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                CategoryChip(label: "All", emoji: "🌿", isSelected: selectedCategory == nil) {
                    withAnimation(.easeInOut(duration: 0.2)) { selectedCategory = nil }
                }
                ForEach(TipCategory.allCases) { cat in
                    CategoryChip(
                        label: cat.displayName,
                        emoji: cat.emoji,
                        isSelected: selectedCategory == cat
                    ) {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedCategory = (selectedCategory == cat) ? nil : cat
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
        }
    }

    // MARK: - Search Bar

    private var searchBar: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(AppColors.textSecondary)

            TextField("Search tips by plant or topic...", text: $searchText)
                .font(.system(.subheadline, design: .rounded))
                .foregroundColor(AppColors.textPrimary)
                .autocorrectionDisabled()

            if !searchText.isEmpty {
                Button {
                    searchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 14))
                        .foregroundColor(AppColors.textSecondary)
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(Color.white.opacity(0.06))
        .cornerRadius(10)
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "text.bubble")
                .font(.system(size: 48, weight: .ultraLight))
                .foregroundColor(AppColors.textSecondary.opacity(0.4))

            Text("No tips found")
                .font(.system(.title3, design: .rounded))
                .fontWeight(.bold)
                .foregroundColor(AppColors.textSecondary)

            Text("Try a different search or category")
                .font(.system(.subheadline, design: .rounded))
                .foregroundColor(AppColors.textSecondary.opacity(0.7))
            Spacer()
        }
    }

    // MARK: - Helpers

    private func formatNumber(_ n: Int) -> String {
        if n >= 10000 {
            return String(format: "%.0fK", Double(n) / 1000)
        } else if n >= 1000 {
            return String(format: "%.1fK", Double(n) / 1000)
        }
        return "\(n)"
    }
}

// MARK: - Category Chip

struct CategoryChip: View {
    let label: String
    let emoji: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Text(emoji)
                    .font(.system(size: 12))
                Text(label)
                    .font(.system(.caption, design: .rounded))
                    .fontWeight(.semibold)
            }
            .foregroundColor(isSelected ? .black : AppColors.textSecondary)
            .padding(.horizontal, 12)
            .padding(.vertical, 7)
            .background(
                Capsule()
                    .fill(isSelected ? AppColors.emerald : Color.white.opacity(0.05))
            )
            .overlay(
                Capsule()
                    .stroke(isSelected ? AppColors.emerald.opacity(0.3) : Color.white.opacity(0.06), lineWidth: 0.5)
            )
            .shadow(color: isSelected ? AppColors.emerald.opacity(0.2) : .clear, radius: 4, y: 2)
        }
    }
}
