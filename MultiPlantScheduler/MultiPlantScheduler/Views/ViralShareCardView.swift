import SwiftUI
import CoreImage.CIFilterBuiltins

/// 9:16 vertical share card optimized for TikTok/Instagram Stories
/// Renders a beautiful branded card with blurred background, plant info, and CTA
struct ViralShareCardView: View {
    let plantName: String
    let subtitle: String           // e.g. "Diagnosed: Powdery Mildew" or "🔥 14-day care streak"
    let accentText: String?        // e.g. "AI identified in 2 seconds" or "Health Score: 92%"
    let plantImage: UIImage?
    let cardStyle: CardStyle

    enum CardStyle {
        case diagnosis(isHealthy: Bool, diseaseName: String?)
        case careStreak(days: Int)
        case plantShowcase
        case healthScore(percent: Int)
    }

    // 9:16 ratio for Stories
    private let cardWidth: CGFloat = 1080 / 3   // 360pt
    private let cardHeight: CGFloat = 1920 / 3  // 640pt

    var body: some View {
        ZStack {
            // Blurred plant photo background
            if let img = plantImage {
                Image(uiImage: img)
                    .resizable()
                    .scaledToFill()
                    .frame(width: cardWidth, height: cardHeight)
                    .clipped()
                    .blur(radius: 30)
                    .overlay(Color.black.opacity(0.55))
            } else {
                LinearGradient(
                    colors: [
                        Color(red: 0.03, green: 0.12, blue: 0.05),
                        Color(red: 0.05, green: 0.05, blue: 0.05),
                        Color(red: 0.02, green: 0.08, blue: 0.03)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            }

            VStack(spacing: 0) {
                // Top branding
                topBranding
                    .padding(.top, 24)

                Spacer()

                // Center: plant photo + info
                centerContent

                Spacer()

                // Bottom: CTA + QR
                bottomCTA
                    .padding(.bottom, 24)
            }
            .padding(.horizontal, 20)
        }
        .frame(width: cardWidth, height: cardHeight)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    // MARK: - Top Branding

    private var topBranding: some View {
        HStack(spacing: 8) {
            Image(systemName: "leaf.fill")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(AppColors.limeGreen)

            Text("MultiPlant AI")
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundColor(.white.opacity(0.9))

            Spacer()

            // Style badge
            Text(styleBadgeText)
                .font(.system(size: 10, weight: .bold, design: .rounded))
                .foregroundColor(.black)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(styleBadgeColor)
                .cornerRadius(6)
        }
    }

    private var styleBadgeText: String {
        switch cardStyle {
        case .diagnosis(let isHealthy, _):
            return isHealthy ? "HEALTHY ✅" : "DIAGNOSED 🔬"
        case .careStreak(let days):
            return "🔥 \(days) DAYS"
        case .plantShowcase:
            return "MY PLANT 🌿"
        case .healthScore(let pct):
            return "\(pct)% HEALTHY"
        }
    }

    private var styleBadgeColor: Color {
        switch cardStyle {
        case .diagnosis(let isHealthy, _):
            return isHealthy ? AppColors.limeGreen : .orange
        case .careStreak:
            return .orange
        case .plantShowcase:
            return AppColors.limeGreen
        case .healthScore(let pct):
            return pct > 70 ? AppColors.limeGreen : .orange
        }
    }

    // MARK: - Center Content

    private var centerContent: some View {
        VStack(spacing: 16) {
            // Plant photo
            if let img = plantImage {
                Image(uiImage: img)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 180, height: 180)
                    .clipShape(RoundedRectangle(cornerRadius: 24))
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(
                                LinearGradient(
                                    colors: [AppColors.limeGreen.opacity(0.6), AppColors.forestGreen.opacity(0.3)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 2
                            )
                    )
                    .shadow(color: AppColors.limeGreen.opacity(0.3), radius: 20, y: 10)
            } else {
                ZStack {
                    RoundedRectangle(cornerRadius: 24)
                        .fill(AppColors.forestGreen.opacity(0.2))
                        .frame(width: 180, height: 180)
                    Image(systemName: "leaf.fill")
                        .font(.system(size: 56, weight: .ultraLight))
                        .foregroundColor(AppColors.limeGreen.opacity(0.5))
                }
            }

            // Plant name
            Text(plantName)
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .shadow(color: .black.opacity(0.5), radius: 4, y: 2)

            // Subtitle
            Text(subtitle)
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundColor(.white.opacity(0.85))
                .multilineTextAlignment(.center)
                .lineLimit(2)

            // Accent text
            if let accent = accentText {
                Text(accent)
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundColor(AppColors.limeGreen)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(AppColors.limeGreen.opacity(0.15))
                            .overlay(
                                Capsule()
                                    .stroke(AppColors.limeGreen.opacity(0.3), lineWidth: 0.5)
                            )
                    )
            }
        }
    }

    // MARK: - Bottom CTA

    private var bottomCTA: some View {
        VStack(spacing: 12) {
            // CTA text
            Text("The app that saved my plants 🌿")
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundColor(.white)

            // App link
            HStack(spacing: 12) {
                // QR Code
                if let qrImage = generateQRCode(from: "https://apps.apple.com/app/multiplant-ai-scheduler/id6745401961") {
                    Image(uiImage: qrImage)
                        .interpolation(.none)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 48, height: 48)
                        .cornerRadius(6)
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(Color.white.opacity(0.2), lineWidth: 0.5)
                        )
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text("MultiPlant AI Scheduler")
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundColor(.white.opacity(0.9))
                    Text("Free on the App Store")
                        .font(.system(size: 10, weight: .medium, design: .rounded))
                        .foregroundColor(AppColors.limeGreen)
                }

                Spacer()
            }
            .padding(10)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.white.opacity(0.08))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.white.opacity(0.1), lineWidth: 0.5)
                    )
            )
        }
    }

    // MARK: - QR Code Generator

    private func generateQRCode(from string: String) -> UIImage? {
        let context = CIContext()
        let filter = CIFilter.qrCodeGenerator()
        filter.message = Data(string.utf8)
        filter.correctionLevel = "M"

        guard let outputImage = filter.outputImage else { return nil }

        // Make it green-tinted
        let colorFilter = CIFilter.falseColor()
        colorFilter.inputImage = outputImage
        colorFilter.color0 = CIColor(color: UIColor(AppColors.limeGreen))
        colorFilter.color1 = CIColor(color: UIColor(red: 0.07, green: 0.07, blue: 0.07, alpha: 1))

        guard let coloredImage = colorFilter.outputImage else { return nil }

        let scale = 256.0 / coloredImage.extent.width
        let scaledImage = coloredImage.transformed(by: CGAffineTransform(scaleX: scale, y: scale))

        guard let cgImage = context.createCGImage(scaledImage, from: scaledImage.extent) else { return nil }
        return UIImage(cgImage: cgImage)
    }
}

// MARK: - Share Card Renderer

struct ShareCardRenderer {

    /// Renders the share card to a UIImage at 1080x1920 (3x scale for 360x640pt)
    @MainActor
    static func render(
        plantName: String,
        subtitle: String,
        accentText: String?,
        plantImage: UIImage?,
        cardStyle: ViralShareCardView.CardStyle
    ) -> UIImage? {
        let view = ViralShareCardView(
            plantName: plantName,
            subtitle: subtitle,
            accentText: accentText,
            plantImage: plantImage,
            cardStyle: cardStyle
        )

        let renderer = ImageRenderer(content: view)
        renderer.scale = 3.0  // 1080x1920
        renderer.isOpaque = true
        return renderer.uiImage
    }

    /// Convenience: render and present share sheet
    @MainActor
    static func shareImage(
        plantName: String,
        subtitle: String,
        accentText: String?,
        plantImage: UIImage?,
        cardStyle: ViralShareCardView.CardStyle
    ) -> UIImage? {
        render(
            plantName: plantName,
            subtitle: subtitle,
            accentText: accentText,
            plantImage: plantImage,
            cardStyle: cardStyle
        )
    }
}
