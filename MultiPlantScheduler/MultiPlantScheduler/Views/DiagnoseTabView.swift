import SwiftUI
import SwiftData
import PhotosUI

/// Main Diagnose tab — camera/photo picker for disease & pest detection
struct DiagnoseTabView: View {
    @Query(sort: \DiagnosisEntry.diagnosisDate, order: .reverse) var allDiagnoses: [DiagnosisEntry]
    @Query(sort: \Plant.createdAt) var plants: [Plant]
    @Environment(\.modelContext) var modelContext
    @EnvironmentObject var revenueCatManager: RevenueCatManager

    @State private var selectedImage: UIImage?
    @State private var imageData: Data?
    @State private var showCamera = false
    @State private var showPhotoPicker = false
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var isAnalyzing = false
    @State private var diagnosisResult: DiagnosisService.DiagnosisResult?
    @State private var showResult = false
    @State private var showPaywall = false
    @State private var showHistory = false
    @State private var selectedPlant: Plant?
    @State private var showPlantPicker = false
    @State private var scanProgress: Double = 0
    @State private var errorMessage: String?

    private let diagnosisService = DiagnosisService.shared

    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        // Hero section
                        heroSection

                        // Credits badge
                        creditsBadge

                        // Photo capture area
                        photoCaptureSection

                        // Link to plant (optional)
                        if selectedImage != nil {
                            plantLinkerSection
                        }

                        // Analyze button
                        if selectedImage != nil && !isAnalyzing {
                            analyzeButton
                        }

                        // Scanning animation
                        if isAnalyzing {
                            scanningOverlay
                        }

                        // Recent diagnoses
                        if !allDiagnoses.isEmpty {
                            recentDiagnosesSection
                        }

                        Spacer(minLength: 40)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                }
            }
            .navigationTitle("Diagnose")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    if !allDiagnoses.isEmpty {
                        Button {
                            showHistory = true
                        } label: {
                            Image(systemName: "clock.arrow.circlepath")
                                .foregroundColor(AppColors.limeGreen)
                        }
                    }
                }
            }
            .sheet(isPresented: $showCamera) {
                DiagnosisCameraView { image in
                    handleCapturedImage(image)
                }
            }
            .photosPicker(isPresented: $showPhotoPicker, selection: $selectedPhotoItem, matching: .images)
            .onChange(of: selectedPhotoItem) { _, newValue in
                Task {
                    if let data = try? await newValue?.loadTransferable(type: Data.self),
                       let uiImage = UIImage(data: data) {
                        handleCapturedImage(uiImage)
                    }
                }
            }
            .fullScreenCover(isPresented: $showPaywall) {
                PaywallView()
            }
            .sheet(isPresented: $showResult) {
                if let result = diagnosisResult {
                    DiagnosisResultView(
                        result: result,
                        imageData: imageData,
                        plant: selectedPlant,
                        onDismiss: {
                            showResult = false
                            resetState()
                        }
                    )
                }
            }
            .sheet(isPresented: $showHistory) {
                NavigationStack {
                    DiagnosisHistoryView()
                }
            }
            .sheet(isPresented: $showPlantPicker) {
                plantPickerSheet
            }
        }
    }

    // MARK: - Hero Section

    private var heroSection: some View {
        VStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [AppColors.emerald.opacity(0.2), AppColors.teal.opacity(0.05), .clear],
                            center: .center,
                            startRadius: 5,
                            endRadius: 50
                        )
                    )
                    .frame(width: 90, height: 90)

                Image(systemName: "microbe.fill")
                    .font(.system(size: 38, weight: .light))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [AppColors.emerald, AppColors.limeGreen],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .shadow(color: AppColors.emerald.opacity(0.3), radius: 8)
            }

            Text("Disease & Pest Detection")
                .font(.system(.title2, design: .rounded))
                .fontWeight(.bold)
                .foregroundColor(AppColors.textPrimary)

            Text("Take a photo of a sick leaf or plant\nand AI will identify the problem")
                .font(.system(.subheadline, design: .rounded))
                .foregroundColor(AppColors.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 8)
    }

    // MARK: - Credits Badge

    private var creditsBadge: some View {
        HStack(spacing: 8) {
            Image(systemName: revenueCatManager.isPremium ? "infinity" : "ticket.fill")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(revenueCatManager.isPremium ? AppColors.emerald : .orange)

            if revenueCatManager.isPremium {
                Text("Unlimited diagnoses")
                    .font(.system(.caption, design: .rounded))
                    .fontWeight(.semibold)
                    .foregroundColor(AppColors.emerald)
            } else {
                Text("\(diagnosisService.creditsRemaining)/\(DiagnosisService.maxFreeDiagnoses) free diagnoses")
                    .font(.system(.caption, design: .rounded))
                    .fontWeight(.semibold)
                    .foregroundColor(diagnosisService.creditsRemaining == 0 ? AppColors.urgencyCritical : .orange)

                Spacer()

                Button {
                    showPaywall = true
                } label: {
                    Text("Get Unlimited")
                        .font(.system(.caption2, design: .rounded))
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(
                            Capsule().fill(PremiumGradient.button)
                        )
                }
            }

            if revenueCatManager.isPremium { Spacer() }
        }
        .premiumGlass(cornerRadius: 12, strokeOpacity: 0.08, padding: 12)
    }

    // MARK: - Photo Capture Section

    private var photoCaptureSection: some View {
        VStack(spacing: 16) {
            if let image = selectedImage {
                // Show selected image
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 240)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(AppColors.forestGreen, lineWidth: 2)
                    )
                    .overlay(alignment: .topTrailing) {
                        Button {
                            resetState()
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 24))
                                .foregroundColor(.white)
                                .shadow(radius: 4)
                        }
                        .padding(12)
                    }
            } else {
                // Empty state with capture buttons
                VStack(spacing: 20) {
                    Image(systemName: "leaf.arrow.triangle.circlepath")
                        .font(.system(size: 44, weight: .ultraLight))
                        .foregroundColor(AppColors.limeGreen.opacity(0.6))

                    HStack(spacing: 16) {
                        captureButton(
                            icon: "camera.fill",
                            label: "Camera",
                            action: { showCamera = true }
                        )

                        captureButton(
                            icon: "photo.on.rectangle",
                            label: "Library",
                            action: { showPhotoPicker = true }
                        )
                    }

                    Text("For best results, photograph the affected area up close")
                        .font(.system(.caption2, design: .rounded))
                        .foregroundColor(AppColors.textSecondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 240)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white.opacity(0.03))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .strokeBorder(
                                    style: StrokeStyle(lineWidth: 1.5, dash: [8, 6])
                                )
                                .foregroundColor(AppColors.forestGreen.opacity(0.4))
                        )
                )
            }
        }
    }

    private func captureButton(icon: String, label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 24, weight: .medium))
                Text(label)
                    .font(.system(.caption, design: .rounded))
                    .fontWeight(.medium)
            }
            .foregroundColor(AppColors.limeGreen)
            .frame(width: 100, height: 80)
            .background(AppColors.forestGreen.opacity(0.15))
            .cornerRadius(12)
        }
    }

    // MARK: - Plant Linker

    private var plantLinkerSection: some View {
        Button {
            showPlantPicker = true
        } label: {
            HStack(spacing: 12) {
                if let plant = selectedPlant, let img = plant.photoImage {
                    img
                        .resizable()
                        .scaledToFill()
                        .frame(width: 36, height: 36)
                        .clipShape(Circle())
                } else {
                    Image(systemName: "leaf.circle")
                        .font(.system(size: 24))
                        .foregroundColor(AppColors.limeGreen)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(selectedPlant?.name ?? "Link to a plant (optional)")
                        .font(.system(.subheadline, design: .rounded))
                        .fontWeight(.medium)
                        .foregroundColor(AppColors.textPrimary)

                    if selectedPlant != nil {
                        Text("Tap to change")
                            .font(.system(.caption2, design: .rounded))
                            .foregroundColor(AppColors.textSecondary)
                    } else {
                        Text("Results will be saved to the plant's history")
                            .font(.system(.caption2, design: .rounded))
                            .foregroundColor(AppColors.textSecondary)
                    }
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(AppColors.textSecondary)
            }
            .padding(12)
            .background(Color.white.opacity(0.05))
            .cornerRadius(10)
        }
    }

    // MARK: - Analyze Button

    private var analyzeButton: some View {
        Button {
            startDiagnosis()
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "wand.and.stars")
                    .font(.system(size: 18, weight: .semibold))
                Text("Analyze for Diseases & Pests")
                    .font(.system(.headline, design: .rounded))
                    .fontWeight(.bold)
            }
            .foregroundColor(.black)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .premiumButton()
        }
        .disabled(!diagnosisService.canDiagnose(isPremium: revenueCatManager.isPremium))
        .opacity(diagnosisService.canDiagnose(isPremium: revenueCatManager.isPremium) ? 1.0 : 0.5)
    }

    // MARK: - Scanning Overlay

    private var scanningOverlay: some View {
        VStack(spacing: 20) {
            ZStack {
                // Pulsing ring
                Circle()
                    .stroke(AppColors.limeGreen.opacity(0.3), lineWidth: 3)
                    .frame(width: 80, height: 80)
                    .scaleEffect(isAnalyzing ? 1.3 : 1.0)
                    .opacity(isAnalyzing ? 0.0 : 1.0)
                    .animation(.easeInOut(duration: 1.2).repeatForever(autoreverses: false), value: isAnalyzing)

                // Progress ring
                Circle()
                    .trim(from: 0, to: scanProgress)
                    .stroke(AppColors.limeGreen, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                    .frame(width: 80, height: 80)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 0.5), value: scanProgress)

                Image(systemName: "microbe.fill")
                    .font(.system(size: 32, weight: .light))
                    .foregroundColor(AppColors.limeGreen)
                    .symbolEffect(.pulse, options: .repeating)
            }

            VStack(spacing: 6) {
                Text("Analyzing plant health...")
                    .font(.system(.headline, design: .rounded))
                    .foregroundColor(AppColors.textPrimary)

                Text("Checking for diseases, pests, and deficiencies")
                    .font(.system(.caption, design: .rounded))
                    .foregroundColor(AppColors.textSecondary)
            }
        }
        .padding(.vertical, 24)
    }

    // MARK: - Recent Diagnoses

    private var recentDiagnosesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Recent Diagnoses")
                    .font(.system(.headline, design: .rounded))
                    .foregroundColor(AppColors.textPrimary)

                Spacer()

                if allDiagnoses.count > 3 {
                    Button("See All") {
                        showHistory = true
                    }
                    .font(.system(.caption, design: .rounded))
                    .foregroundColor(AppColors.limeGreen)
                }
            }

            ForEach(allDiagnoses.prefix(3)) { entry in
                DiagnosisRowView(entry: entry)
            }
        }
    }

    // MARK: - Plant Picker Sheet

    private var plantPickerSheet: some View {
        NavigationStack {
            ZStack {
                AppColors.background.ignoresSafeArea()

                if plants.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "leaf")
                            .font(.system(size: 40, weight: .ultraLight))
                            .foregroundColor(AppColors.textSecondary)
                        Text("No plants yet")
                            .font(.system(.headline, design: .rounded))
                            .foregroundColor(AppColors.textSecondary)
                        Text("Add a plant first to link diagnoses")
                            .font(.system(.caption, design: .rounded))
                            .foregroundColor(AppColors.textSecondary)
                    }
                } else {
                    List {
                        Button {
                            selectedPlant = nil
                            showPlantPicker = false
                        } label: {
                            HStack(spacing: 12) {
                                Image(systemName: "xmark.circle")
                                    .foregroundColor(AppColors.textSecondary)
                                Text("No plant (standalone diagnosis)")
                                    .foregroundColor(AppColors.textSecondary)
                            }
                        }
                        .listRowBackground(Color.white.opacity(0.05))

                        ForEach(plants) { plant in
                            Button {
                                selectedPlant = plant
                                showPlantPicker = false
                            } label: {
                                HStack(spacing: 12) {
                                    if let img = plant.photoImage {
                                        img
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 40, height: 40)
                                            .clipShape(Circle())
                                    } else {
                                        Circle()
                                            .fill(AppColors.forestGreen.opacity(0.3))
                                            .frame(width: 40, height: 40)
                                            .overlay {
                                                Image(systemName: "leaf.fill")
                                                    .foregroundColor(.white.opacity(0.6))
                                            }
                                    }

                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(plant.name)
                                            .font(.system(.subheadline, design: .rounded))
                                            .fontWeight(.medium)
                                            .foregroundColor(AppColors.textPrimary)
                                        if let species = plant.species {
                                            Text(species)
                                                .font(.system(.caption2, design: .rounded))
                                                .foregroundColor(AppColors.textSecondary)
                                        }
                                    }

                                    Spacer()

                                    if selectedPlant?.id == plant.id {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(AppColors.limeGreen)
                                    }
                                }
                            }
                            .listRowBackground(Color.white.opacity(0.05))
                        }
                    }
                    .scrollContentBackground(.hidden)
                }
            }
            .navigationTitle("Link to Plant")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { showPlantPicker = false }
                }
            }
        }
    }

    // MARK: - Actions

    private func handleCapturedImage(_ image: UIImage) {
        selectedImage = image
        imageData = image.jpegData(compressionQuality: 0.7)
        diagnosisResult = nil
        errorMessage = nil
    }

    private func resetState() {
        selectedImage = nil
        imageData = nil
        diagnosisResult = nil
        selectedPhotoItem = nil
        selectedPlant = nil
        scanProgress = 0
        errorMessage = nil
    }

    private func startDiagnosis() {
        guard let image = selectedImage else { return }

        guard diagnosisService.canDiagnose(isPremium: revenueCatManager.isPremium) else {
            showPaywall = true
            return
        }

        isAnalyzing = true
        scanProgress = 0

        // Animate progress
        let progressTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            withAnimation {
                if scanProgress < 0.85 {
                    scanProgress += 0.02
                }
            }
            if !isAnalyzing {
                timer.invalidate()
            }
        }

        Task {
            // Minimum 2s animation
            async let resultTask = diagnosisService.diagnose(image: image, isPremium: revenueCatManager.isPremium)
            async let minDelay: Void = try await Task.sleep(nanoseconds: 2_000_000_000)

            let result = await resultTask
            _ = try? await minDelay

            progressTimer.invalidate()

            await MainActor.run {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                    scanProgress = 1.0
                }
            }

            try? await Task.sleep(nanoseconds: 300_000_000)

            await MainActor.run {
                isAnalyzing = false
                if let result = result {
                    diagnosisResult = result
                    // Save to SwiftData
                    saveDiagnosis(result)
                    // Haptic
                    let feedback = UINotificationFeedbackGenerator()
                    feedback.notificationOccurred(result.isHealthy ? .success : .warning)
                    // Show result
                    showResult = true
                } else {
                    errorMessage = "Could not analyze the image. Please try again."
                    let feedback = UINotificationFeedbackGenerator()
                    feedback.notificationOccurred(.error)
                }
            }
        }
    }

    private func saveDiagnosis(_ result: DiagnosisService.DiagnosisResult) {
        if result.isHealthy || result.diseases.isEmpty {
            // Save healthy result
            let entry = DiagnosisService.createEntry(
                from: result,
                issue: nil,
                imageData: imageData,
                plant: selectedPlant
            )
            modelContext.insert(entry)
        } else {
            // Save the top issue
            let topIssue = result.diseases.first
            let entry = DiagnosisService.createEntry(
                from: result,
                issue: topIssue,
                imageData: imageData,
                plant: selectedPlant
            )
            modelContext.insert(entry)
        }

        try? modelContext.save()
    }
}

// MARK: - Diagnosis Row View

struct DiagnosisRowView: View {
    let entry: DiagnosisEntry

    var body: some View {
        HStack(spacing: 12) {
            // Thumbnail
            if let img = entry.photoImage {
                img
                    .resizable()
                    .scaledToFill()
                    .frame(width: 48, height: 48)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            } else {
                RoundedRectangle(cornerRadius: 8)
                    .fill(entry.diagnosisCategory.color.opacity(0.2))
                    .frame(width: 48, height: 48)
                    .overlay {
                        Image(systemName: entry.diagnosisCategory.iconName)
                            .foregroundColor(entry.diagnosisCategory.color)
                    }
            }

            // Info
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(entry.isHealthy ? "Healthy" : (entry.diseaseName ?? "Unknown Issue"))
                        .font(.system(.subheadline, design: .rounded))
                        .fontWeight(.semibold)
                        .foregroundColor(AppColors.textPrimary)
                        .lineLimit(1)

                    if !entry.isHealthy {
                        Text(entry.severityLevel.displayName)
                            .font(.system(.caption2, design: .rounded))
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(entry.severityLevel.color)
                            .cornerRadius(4)
                    }
                }

                HStack(spacing: 4) {
                    if let plant = entry.plant {
                        Text(plant.name)
                            .font(.system(.caption2, design: .rounded))
                            .foregroundColor(AppColors.limeGreen)
                        Text("·")
                            .foregroundColor(AppColors.textSecondary)
                    }

                    Text(entry.diagnosisDate, style: .relative)
                        .font(.system(.caption2, design: .rounded))
                        .foregroundColor(AppColors.textSecondary)
                }
            }

            Spacer()

            // Category icon
            Image(systemName: entry.isHealthy ? "checkmark.circle.fill" : entry.diagnosisCategory.iconName)
                .font(.system(size: 18))
                .foregroundColor(entry.isHealthy ? AppColors.forestGreen : entry.diagnosisCategory.color)
        }
        .premiumGlass(cornerRadius: 12, strokeOpacity: 0.06, padding: 12)
    }
}

// MARK: - Camera View (reusable)

struct DiagnosisCameraView: UIViewControllerRepresentable {
    let onImagePicked: (UIImage) -> Void
    @Environment(\.dismiss) var dismiss

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: DiagnosisCameraView

        init(parent: DiagnosisCameraView) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.onImagePicked(image)
            }
            parent.dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}
