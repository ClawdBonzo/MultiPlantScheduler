import SwiftUI
import SwiftData
import PhotosUI

/// Form for sharing a new community tip
struct ShareTipView: View {
    let plants: [Plant]
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss

    @State private var plantName = ""
    @State private var tipTitle = ""
    @State private var tipDescription = ""
    @State private var selectedCategory: TipCategory = .care
    @State private var selectedPlant: Plant?
    @State private var showPlantPicker = false
    @State private var photoItem: PhotosPickerItem?
    @State private var photoData: Data?
    @State private var showSuccess = false

    private var isValid: Bool {
        !plantName.trimmingCharacters(in: .whitespaces).isEmpty &&
        !tipTitle.trimmingCharacters(in: .whitespaces).isEmpty &&
        tipDescription.trimmingCharacters(in: .whitespaces).count >= 10
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        // Hero
                        VStack(spacing: 10) {
                            ZStack {
                                Circle()
                                    .fill(AppColors.limeGreen.opacity(0.15))
                                    .frame(width: 64, height: 64)
                                Image(systemName: "plus.bubble.fill")
                                    .font(.system(size: 28, weight: .light))
                                    .foregroundColor(AppColors.limeGreen)
                            }

                            Text("Share Your Knowledge")
                                .font(.system(.title3, design: .rounded))
                                .fontWeight(.bold)
                                .foregroundColor(AppColors.textPrimary)

                            Text("Help other plant parents with your experience")
                                .font(.system(.caption, design: .rounded))
                                .foregroundColor(AppColors.textSecondary)
                        }

                        // Plant selection
                        VStack(alignment: .leading, spacing: 8) {
                            fieldLabel("Plant")

                            if let plant = selectedPlant {
                                HStack(spacing: 10) {
                                    if let img = plant.photoImage {
                                        img
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 32, height: 32)
                                            .clipShape(Circle())
                                    }
                                    Text(plant.name)
                                        .font(.system(.subheadline, design: .rounded))
                                        .fontWeight(.medium)
                                        .foregroundColor(AppColors.textPrimary)

                                    Spacer()

                                    Button("Change") {
                                        showPlantPicker = true
                                    }
                                    .font(.system(.caption, design: .rounded))
                                    .foregroundColor(AppColors.limeGreen)
                                }
                                .padding(12)
                                .background(Color.white.opacity(0.06))
                                .cornerRadius(10)
                            } else {
                                HStack {
                                    TextField("Plant name (e.g. Monstera)", text: $plantName)
                                        .font(.system(.subheadline, design: .rounded))
                                        .foregroundColor(AppColors.textPrimary)

                                    if !plants.isEmpty {
                                        Button {
                                            showPlantPicker = true
                                        } label: {
                                            Text("Pick from garden")
                                                .font(.system(.caption2, design: .rounded))
                                                .foregroundColor(AppColors.limeGreen)
                                        }
                                    }
                                }
                                .padding(12)
                                .background(Color.white.opacity(0.06))
                                .cornerRadius(10)
                            }
                        }

                        // Category picker
                        VStack(alignment: .leading, spacing: 8) {
                            fieldLabel("Category")

                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    ForEach(TipCategory.allCases) { cat in
                                        Button {
                                            withAnimation(.easeInOut(duration: 0.2)) {
                                                selectedCategory = cat
                                            }
                                        } label: {
                                            HStack(spacing: 4) {
                                                Text(cat.emoji)
                                                    .font(.system(size: 12))
                                                Text(cat.displayName)
                                                    .font(.system(.caption, design: .rounded))
                                                    .fontWeight(.semibold)
                                            }
                                            .foregroundColor(selectedCategory == cat ? .black : AppColors.textSecondary)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 7)
                                            .background(
                                                Capsule()
                                                    .fill(selectedCategory == cat ? cat.color : Color.white.opacity(0.06))
                                            )
                                        }
                                    }
                                }
                            }
                        }

                        // Tip title
                        VStack(alignment: .leading, spacing: 8) {
                            fieldLabel("Tip Title")
                            TextField("e.g. Bottom watering changed everything", text: $tipTitle)
                                .font(.system(.subheadline, design: .rounded))
                                .foregroundColor(AppColors.textPrimary)
                                .padding(12)
                                .background(Color.white.opacity(0.06))
                                .cornerRadius(10)
                        }

                        // Description
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                fieldLabel("Your Tip")
                                Spacer()
                                let charCount = tipDescription.count
                                Text("\(charCount)/500")
                                    .font(.system(.caption2, design: .rounded))
                                    .foregroundColor(charCount > 450 ? .orange : AppColors.textSecondary)
                            }

                            TextField("Share what worked for you in detail...", text: $tipDescription, axis: .vertical)
                                .font(.system(.subheadline, design: .rounded))
                                .foregroundColor(AppColors.textPrimary)
                                .lineLimit(4...8)
                                .padding(12)
                                .background(Color.white.opacity(0.06))
                                .cornerRadius(10)
                                .onChange(of: tipDescription) { _, newValue in
                                    if newValue.count > 500 {
                                        tipDescription = String(newValue.prefix(500))
                                    }
                                }
                        }

                        // Photo (optional)
                        VStack(alignment: .leading, spacing: 8) {
                            fieldLabel("Photo (optional)")

                            if let photoData = photoData,
                               let uiImage = UIImage(data: photoData) {
                                ZStack(alignment: .topTrailing) {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(height: 140)
                                        .clipShape(RoundedRectangle(cornerRadius: 10))

                                    Button {
                                        self.photoData = nil
                                        self.photoItem = nil
                                    } label: {
                                        Image(systemName: "xmark.circle.fill")
                                            .font(.system(size: 22))
                                            .foregroundColor(.white)
                                            .shadow(radius: 4)
                                    }
                                    .padding(8)
                                }
                            } else {
                                PhotosPicker(selection: $photoItem, matching: .images) {
                                    HStack(spacing: 8) {
                                        Image(systemName: "photo.badge.plus")
                                            .font(.system(size: 16))
                                        Text("Add a photo")
                                            .font(.system(.caption, design: .rounded))
                                            .fontWeight(.medium)
                                    }
                                    .foregroundColor(AppColors.limeGreen)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                                    .background(
                                        RoundedRectangle(cornerRadius: 10)
                                            .strokeBorder(
                                                style: StrokeStyle(lineWidth: 1, dash: [6, 4])
                                            )
                                            .foregroundColor(AppColors.forestGreen.opacity(0.4))
                                    )
                                }
                            }
                        }
                        .onChange(of: photoItem) { _, newValue in
                            Task {
                                if let data = try? await newValue?.loadTransferable(type: Data.self) {
                                    if let img = UIImage(data: data),
                                       let compressed = img.jpegData(compressionQuality: 0.6) {
                                        photoData = compressed
                                    }
                                }
                            }
                        }

                        // Submit button
                        Button {
                            submitTip()
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "paperplane.fill")
                                Text("Share with Community")
                            }
                            .font(.system(.headline, design: .rounded))
                            .fontWeight(.bold)
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                isValid
                                    ? LinearGradient(
                                        colors: [AppColors.limeGreen, AppColors.forestGreen],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                    : LinearGradient(
                                        colors: [Color.gray.opacity(0.3), Color.gray.opacity(0.3)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                            )
                            .cornerRadius(14)
                        }
                        .disabled(!isValid)

                        Spacer(minLength: 40)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                }

                // Success overlay
                if showSuccess {
                    Color.black.opacity(0.7)
                        .ignoresSafeArea()
                        .transition(.opacity)

                    VStack(spacing: 16) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 56, weight: .light))
                            .foregroundColor(AppColors.limeGreen)

                        Text("Tip Shared!")
                            .font(.system(.title2, design: .rounded))
                            .fontWeight(.bold)
                            .foregroundColor(AppColors.textPrimary)

                        Text("Thank you for helping the community")
                            .font(.system(.subheadline, design: .rounded))
                            .foregroundColor(AppColors.textSecondary)
                    }
                    .transition(.scale.combined(with: .opacity))
                }
            }
            .navigationTitle("Share a Tip")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .sheet(isPresented: $showPlantPicker) {
                plantPickerSheet
            }
        }
    }

    // MARK: - Helpers

    private func fieldLabel(_ text: String) -> some View {
        Text(text)
            .font(.system(.caption, design: .rounded))
            .fontWeight(.semibold)
            .foregroundColor(AppColors.textSecondary)
    }

    private func submitTip() {
        let name = selectedPlant?.name ?? plantName.trimmingCharacters(in: .whitespaces)
        guard !name.isEmpty else { return }

        let tip = CommunityTip(
            plantName: name,
            tipTitle: tipTitle.trimmingCharacters(in: .whitespaces),
            tipDescription: tipDescription.trimmingCharacters(in: .whitespaces),
            category: selectedCategory.rawValue,
            helpfulCount: 0,
            authorName: "You",
            isSeeded: false,
            photoData: photoData
        )

        modelContext.insert(tip)
        try? modelContext.save()

        let feedback = UINotificationFeedbackGenerator()
        feedback.notificationOccurred(.success)

        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
            showSuccess = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            dismiss()
        }
    }

    // MARK: - Plant Picker Sheet

    private var plantPickerSheet: some View {
        NavigationStack {
            ZStack {
                AppColors.background.ignoresSafeArea()

                List {
                    ForEach(plants) { plant in
                        Button {
                            selectedPlant = plant
                            plantName = plant.name
                            showPlantPicker = false
                        } label: {
                            HStack(spacing: 12) {
                                if let img = plant.photoImage {
                                    img
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 36, height: 36)
                                        .clipShape(Circle())
                                } else {
                                    Circle()
                                        .fill(AppColors.forestGreen.opacity(0.3))
                                        .frame(width: 36, height: 36)
                                        .overlay {
                                            Image(systemName: "leaf.fill")
                                                .foregroundColor(.white.opacity(0.6))
                                        }
                                }
                                Text(plant.name)
                                    .font(.system(.subheadline, design: .rounded))
                                    .fontWeight(.medium)
                                    .foregroundColor(AppColors.textPrimary)
                                Spacer()
                            }
                        }
                        .listRowBackground(Color.white.opacity(0.05))
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Select Plant")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { showPlantPicker = false }
                }
            }
        }
    }
}
