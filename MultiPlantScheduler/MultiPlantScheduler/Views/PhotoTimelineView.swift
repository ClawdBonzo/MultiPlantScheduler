import SwiftUI
import PhotosUI
import SwiftData

/// Timeline view showing a plant's photo history for tracking growth
struct PhotoTimelineView: View {
    @Bindable var plant: Plant
    @Environment(\.modelContext) var modelContext
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var selectedPhotoForFullScreen: PhotoEntry?

    private var sortedPhotos: [PhotoEntry] {
        plant.photoEntries.sorted { $0.captureDate > $1.captureDate }
    }

    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 16) {
                    // Add photo button
                    PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                        HStack {
                            Image(systemName: "camera.fill")
                            Text("Add Photo")
                        }
                        .font(.headline)
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(AppColors.limeGreen)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }

                    // Compare button
                    if sortedPhotos.count >= 2 {
                        NavigationLink {
                            PhotoCompareView(photos: sortedPhotos)
                        } label: {
                            HStack {
                                Image(systemName: "rectangle.on.rectangle")
                                Text("Compare Photos")
                            }
                            .font(.subheadline)
                            .foregroundStyle(AppColors.limeGreen)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(AppColors.limeGreen.opacity(0.15))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }

                    // Photo timeline
                    if sortedPhotos.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "photo.on.rectangle.angled")
                                .font(.largeTitle)
                                .foregroundStyle(AppColors.textSecondary)
                            Text("No photos yet")
                                .foregroundStyle(AppColors.textSecondary)
                            Text("Add photos over time to track your plant's growth")
                                .font(.caption)
                                .foregroundStyle(AppColors.textSecondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.top, 40)
                    } else {
                        ForEach(sortedPhotos) { entry in
                            PhotoTimelineRow(entry: entry) {
                                selectedPhotoForFullScreen = entry
                            }
                        }
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Photo Timeline")
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: selectedPhotoItem) { _, newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self) {
                    let entry = PhotoEntry(photoData: data, plant: plant)
                    plant.photoEntries.append(entry)
                    try? modelContext.save()
                }
                selectedPhotoItem = nil
            }
        }
        .fullScreenCover(item: $selectedPhotoForFullScreen) { entry in
            FullScreenPhotoView(entry: entry)
        }
    }
}

/// A single row in the photo timeline
struct PhotoTimelineRow: View {
    let entry: PhotoEntry
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 8) {
                if let image = entry.photoImage {
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: .infinity)
                        .frame(height: 200)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }

                HStack {
                    Text(entry.captureDate, style: .date)
                        .font(.caption)
                        .foregroundStyle(AppColors.textSecondary)
                    if let notes = entry.notes, !notes.isEmpty {
                        Text("- \(notes)")
                            .font(.caption)
                            .foregroundStyle(AppColors.textSecondary)
                            .lineLimit(1)
                    }
                }
            }
        }
    }
}

/// Full screen photo viewer
struct FullScreenPhotoView: View {
    let entry: PhotoEntry
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            if let image = entry.photoImage {
                image
                    .resizable()
                    .scaledToFit()
            }

            VStack {
                HStack {
                    Spacer()
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title)
                            .foregroundStyle(.white.opacity(0.7))
                    }
                    .padding()
                }
                Spacer()
                Text(entry.captureDate, style: .date)
                    .foregroundStyle(.white.opacity(0.7))
                    .padding()
            }
        }
    }
}
