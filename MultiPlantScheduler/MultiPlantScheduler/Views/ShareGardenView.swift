import SwiftUI

/// View for previewing and sharing a garden card image
struct ShareGardenView: View {
    let plants: [Plant]
    @Environment(\.dismiss) var dismiss

    private var maxStreak: Int {
        plants.map(\.wateringStreak).max() ?? 0
    }

    @State private var renderedImage: UIImage?

    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background.ignoresSafeArea()

                VStack(spacing: 20) {
                    Text("Share Your Garden")
                        .font(.headline)
                        .foregroundStyle(AppColors.textPrimary)

                    // Preview
                    GardenCardView(plants: plants, maxStreak: maxStreak)
                        .scaleEffect(0.85)

                    // Share button
                    if let image = renderedImage {
                        ShareLink(
                            item: Image(uiImage: image),
                            preview: SharePreview("My Garden", image: Image(uiImage: image))
                        ) {
                            HStack {
                                Image(systemName: "square.and.arrow.up")
                                Text("Share")
                            }
                            .font(.headline)
                            .foregroundStyle(.black)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(AppColors.limeGreen)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                        }
                        .padding(.horizontal)
                    } else {
                        ProgressView()
                            .tint(.white)
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
            }
            .onAppear {
                renderCard()
            }
        }
    }

    private func renderCard() {
        let cardView = GardenCardView(plants: plants, maxStreak: maxStreak)
        let renderer = ImageRenderer(content: cardView)
        renderer.scale = 3.0 // Retina quality
        renderedImage = renderer.uiImage
    }
}
