import SwiftUI

/// Side-by-side photo comparison view for tracking plant growth
struct PhotoCompareView: View {
    let photos: [PhotoEntry]
    @State private var leftIndex = 0
    @State private var rightIndex = 1

    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()

            VStack(spacing: 16) {
                // Side-by-side photos
                HStack(spacing: 8) {
                    PhotoComparePanel(
                        entry: photos[leftIndex],
                        label: "Before"
                    )
                    PhotoComparePanel(
                        entry: photos[rightIndex],
                        label: "After"
                    )
                }

                // Photo selectors
                HStack(spacing: 20) {
                    VStack {
                        Text("Before")
                            .font(.caption)
                            .foregroundStyle(AppColors.textSecondary)
                        Picker("Before", selection: $leftIndex) {
                            ForEach(photos.indices, id: \.self) { index in
                                Text(photos[index].captureDate, style: .date)
                                    .tag(index)
                            }
                        }
                        .pickerStyle(.menu)
                        .tint(AppColors.limeGreen)
                    }

                    Image(systemName: "arrow.right")
                        .foregroundStyle(AppColors.textSecondary)

                    VStack {
                        Text("After")
                            .font(.caption)
                            .foregroundStyle(AppColors.textSecondary)
                        Picker("After", selection: $rightIndex) {
                            ForEach(photos.indices, id: \.self) { index in
                                Text(photos[index].captureDate, style: .date)
                                    .tag(index)
                            }
                        }
                        .pickerStyle(.menu)
                        .tint(AppColors.limeGreen)
                    }
                }
                .padding()
            }
            .padding()
        }
        .navigationTitle("Compare")
        .navigationBarTitleDisplayMode(.inline)
    }
}

/// A single panel in the comparison view
struct PhotoComparePanel: View {
    let entry: PhotoEntry
    let label: String

    var body: some View {
        VStack(spacing: 8) {
            if let image = entry.photoImage {
                image
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity)
                    .frame(height: 300)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            } else {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.05))
                    .frame(height: 300)
                    .overlay {
                        Text("No photo")
                            .foregroundStyle(AppColors.textSecondary)
                    }
            }
            Text(entry.captureDate, style: .date)
                .font(.caption)
                .foregroundStyle(AppColors.textSecondary)
        }
    }
}
