import SwiftUI

/// Trial countdown banner shown in settings or tabs
struct TrialBannerView: View {
    let remainingDays: Int
    let onTapUpgrade: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Premium Trial Active")
                        .font(.headline)
                        .foregroundColor(AppText.primary)

                    Text("\(remainingDays) day\(remainingDays == 1 ? "" : "s") remaining")
                        .font(.caption)
                        .foregroundColor(AppText.secondary)
                }

                Spacer()

                VStack(alignment: .center, spacing: 2) {
                    Text(String(remainingDays))
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(AppBrand.primary)
                    Text("days left")
                        .font(.caption2)
                        .foregroundColor(AppText.secondary)
                }
                .frame(width: 60)
                .padding(12)
                .background(AppSurface.tertiary)
                .cornerRadius(10)
            }

            // Progress bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(AppSurface.tertiary)
                        .frame(height: 6)

                    Capsule()
                        .fill(AppBrand.primary)
                        .frame(width: max(0, CGFloat(remainingDays) / 3.0 * (geo.size.width)), height: 6)
                }
            }
            .frame(height: 6)

            Button(action: onTapUpgrade) {
                Text("Upgrade to Premium")
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .foregroundColor(.black)
                    .background(AppBrand.primary)
                    .cornerRadius(10)
            }
        }
        .padding(16)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    AppBrand.primary.opacity(0.1),
                    AppBrand.secondary.opacity(0.05)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(14)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(AppBrand.primary.opacity(0.2), lineWidth: 1)
        )
    }
}

#Preview {
    VStack {
        TrialBannerView(remainingDays: 2) {}
        Spacer()
    }
    .padding(24)
    .background(AppSurface.primary)
}
