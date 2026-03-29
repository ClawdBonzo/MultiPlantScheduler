import SwiftUI
import SwiftData

/// Modal view for recording a plant health check-in
struct HealthCheckView: View {
    @Bindable var plant: Plant
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss
    @State private var selectedStatus: HealthStatus = .unknown
    @State private var notes: String = ""

    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        // Plant header
                        VStack(spacing: 12) {
                            if let image = plant.photoImage {
                                image
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 80, height: 80)
                                    .clipShape(Circle())
                            } else {
                                Circle()
                                    .fill(AppColors.forestGreen.opacity(0.3))
                                    .frame(width: 80, height: 80)
                                    .overlay {
                                        Image(systemName: "leaf.fill")
                                            .font(.system(size: 28, weight: .light))
                                            .foregroundStyle(.white.opacity(0.6))
                                    }
                            }
                            Text(plant.name)
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundStyle(AppColors.textPrimary)
                            Text("How is this plant doing?")
                                .font(.subheadline)
                                .foregroundStyle(AppColors.textSecondary)
                        }

                        // Health status options
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 12) {
                            ForEach(HealthStatus.allCases, id: \.self) { status in
                                HealthStatusCard(
                                    status: status,
                                    isSelected: selectedStatus == status
                                ) {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        selectedStatus = status
                                    }
                                }
                            }
                        }

                        // Notes
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Notes (optional)")
                                .font(.subheadline)
                                .foregroundStyle(AppColors.textSecondary)
                            TextField("Any observations...", text: $notes, axis: .vertical)
                                .lineLimit(3...5)
                                .textFieldStyle(.roundedBorder)
                        }

                        // Save button
                        Button {
                            saveHealthCheck()
                        } label: {
                            Text("Save Health Check")
                                .font(.headline)
                                .foregroundStyle(.black)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(AppColors.limeGreen)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .disabled(selectedStatus == .unknown)
                    }
                    .padding()
                }
            }
            .navigationTitle("Health Check")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }

    private func saveHealthCheck() {
        let entry = HealthEntry(
            status: selectedStatus,
            notes: notes.isEmpty ? nil : notes,
            plant: plant
        )
        plant.healthEntries.append(entry)
        plant.healthStatus = selectedStatus.rawValue
        plant.lastHealthCheckDate = Date.now

        try? modelContext.save()

        let feedback = UINotificationFeedbackGenerator()
        feedback.notificationOccurred(.success)

        dismiss()
    }
}

/// A tappable health status card
struct HealthStatusCard: View {
    let status: HealthStatus
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                Text(status.emoji)
                    .font(.largeTitle)
                Text(status.displayName)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(AppColors.textPrimary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? status.color.opacity(0.2) : Color.white.opacity(0.05))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? status.color : Color.clear, lineWidth: 2)
            )
        }
    }
}
