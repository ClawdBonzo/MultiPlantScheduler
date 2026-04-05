import SwiftUI
import SwiftData

/// Shows diagnosis history filtered to a specific plant
struct PlantDiagnosisHistoryView: View {
    let plant: Plant
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var modelContext

    var sortedDiagnoses: [DiagnosisEntry] {
        plant.diagnosisEntries.sorted { $0.diagnosisDate > $1.diagnosisDate }
    }

    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()

            if sortedDiagnoses.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "microbe.fill")
                        .font(.system(size: 44, weight: .ultraLight))
                        .foregroundColor(AppColors.textSecondary.opacity(0.5))

                    Text("No Diagnoses")
                        .font(.system(.title3, design: .rounded))
                        .fontWeight(.bold)
                        .foregroundColor(AppColors.textSecondary)

                    Text("Use the Diagnose tab to scan\n\(plant.name) for diseases and pests")
                        .font(.system(.subheadline, design: .rounded))
                        .foregroundColor(AppColors.textSecondary.opacity(0.7))
                        .multilineTextAlignment(.center)
                }
            } else {
                ScrollView {
                    LazyVStack(spacing: 10) {
                        ForEach(sortedDiagnoses) { entry in
                            DiagnosisHistoryRow(entry: entry)
                                .contextMenu {
                                    Button(role: .destructive) {
                                        modelContext.delete(entry)
                                        try? modelContext.save()
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                }
            }
        }
        .navigationTitle("Diagnoses — \(plant.name)")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Done") { dismiss() }
                    .font(.system(.body, design: .rounded))
                    .fontWeight(.semibold)
                    .foregroundColor(AppColors.limeGreen)
            }
        }
    }
}
