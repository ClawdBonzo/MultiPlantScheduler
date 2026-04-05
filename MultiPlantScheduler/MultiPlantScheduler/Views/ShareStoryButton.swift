import SwiftUI

/// Reusable one-tap "Share to Stories" button with TikTok/Instagram styling
struct ShareStoryButton: View {
    let plantName: String
    let subtitle: String
    let accentText: String?
    let plantImage: UIImage?
    let cardStyle: ViralShareCardView.CardStyle
    var compact: Bool = false

    @State private var showShareSheet = false
    @State private var renderedImage: UIImage?
    @State private var isRendering = false
    @State private var buttonScale: CGFloat = 1.0

    var body: some View {
        Button {
            let impact = UIImpactFeedbackGenerator(style: .medium)
            impact.impactOccurred()

            withAnimation(.spring(response: 0.2, dampingFraction: 0.5)) {
                buttonScale = 0.9
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                withAnimation(.spring(response: 0.25, dampingFraction: 0.6)) {
                    buttonScale = 1.0
                }
            }

            renderAndShare()
        } label: {
            if compact {
                compactLabel
            } else {
                fullLabel
            }
        }
        .scaleEffect(buttonScale)
        .sheet(isPresented: $showShareSheet) {
            if let image = renderedImage {
                ViralShareSheet(image: image, plantName: plantName)
            }
        }
    }

    // MARK: - Labels

    private var fullLabel: some View {
        HStack(spacing: 10) {
            if isRendering {
                ProgressView()
                    .tint(.black)
                    .scaleEffect(0.8)
            } else {
                Image(systemName: "square.and.arrow.up.fill")
                    .font(.system(size: 15, weight: .semibold))
            }

            VStack(alignment: .leading, spacing: 1) {
                Text("Share to Stories")
                    .font(.system(.subheadline, design: .rounded))
                    .fontWeight(.bold)
                Text("TikTok · Instagram · More")
                    .font(.system(size: 9, weight: .medium, design: .rounded))
                    .opacity(0.7)
            }
        }
        .foregroundColor(.black)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(
            LinearGradient(
                colors: [AppColors.limeGreen, AppColors.limeGreen.opacity(0.85)],
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .cornerRadius(12)
    }

    private var compactLabel: some View {
        HStack(spacing: 6) {
            Image(systemName: "square.and.arrow.up.fill")
                .font(.system(size: 12, weight: .semibold))
            Text("Share")
                .font(.system(.caption, design: .rounded))
                .fontWeight(.bold)
        }
        .foregroundColor(.black)
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(AppColors.limeGreen)
        .cornerRadius(8)
    }

    // MARK: - Render

    private func renderAndShare() {
        isRendering = true
        Task { @MainActor in
            renderedImage = ShareCardRenderer.render(
                plantName: plantName,
                subtitle: subtitle,
                accentText: accentText,
                plantImage: plantImage,
                cardStyle: cardStyle
            )
            isRendering = false
            if renderedImage != nil {
                showShareSheet = true
            }
        }
    }
}

// MARK: - Viral Share Sheet (UIActivityViewController with custom items)

struct ViralShareSheet: UIViewControllerRepresentable {
    let image: UIImage
    let plantName: String

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let text = "My \(plantName) is thriving with MultiPlant AI! 🌿\n\nGet the app: https://apps.apple.com/app/multiplant-ai-scheduler/id6745401961"
        let items: [Any] = [image, text]
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        controller.excludedActivityTypes = [.addToReadingList, .assignToContact]
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: - Inline Share Row (for embedding in lists)

struct ShareStoryRow: View {
    let plantName: String
    let subtitle: String
    let accentText: String?
    let plantImage: UIImage?
    let cardStyle: ViralShareCardView.CardStyle

    @State private var showShareSheet = false
    @State private var renderedImage: UIImage?

    var body: some View {
        Button {
            let impact = UIImpactFeedbackGenerator(style: .light)
            impact.impactOccurred()
            renderAndShare()
        } label: {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.purple, .pink, .orange],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 36, height: 36)
                    Image(systemName: "camera.fill")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text("Share to Stories")
                        .font(.system(.subheadline, design: .rounded))
                        .fontWeight(.semibold)
                        .foregroundColor(AppColors.textPrimary)
                    Text("Create a viral 9:16 story card")
                        .font(.system(.caption2, design: .rounded))
                        .foregroundColor(AppColors.textSecondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(AppColors.textSecondary)
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(
                                LinearGradient(
                                    colors: [.purple.opacity(0.3), .pink.opacity(0.2), .orange.opacity(0.3)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
            )
        }
        .sheet(isPresented: $showShareSheet) {
            if let image = renderedImage {
                ViralShareSheet(image: image, plantName: plantName)
            }
        }
    }

    private func renderAndShare() {
        Task { @MainActor in
            renderedImage = ShareCardRenderer.render(
                plantName: plantName,
                subtitle: subtitle,
                accentText: accentText,
                plantImage: plantImage,
                cardStyle: cardStyle
            )
            if renderedImage != nil {
                showShareSheet = true
            }
        }
    }
}
