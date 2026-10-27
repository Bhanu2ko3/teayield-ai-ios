import SwiftUI
import PhotosUI

/// Real-time on-device tea shoot quality scanner and inspection suite (Component 3).
/// Supports live 60fps camera viewfinder scanning and PhotosUI static image analysis.
struct LeafScannerView: View {

    @StateObject private var viewModel: LeafScannerViewModel
    var onRecordWeighingTap: ((Double) -> Void)?

    @State private var selectedPickerItem: PhotosPickerItem?
    @State private var showingDetailSheet = false

    init(
        viewModel: LeafScannerViewModel,
        onRecordWeighingTap: ((Double) -> Void)? = nil
    ) {
        self._viewModel = StateObject(wrappedValue: viewModel)
        self.onRecordWeighingTap = onRecordWeighingTap
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()

                VStack(spacing: 0) {
                    // Top Mode Selector
                    Picker("Scan Mode", selection: $viewModel.scanMode) {
                        ForEach(LeafScanMode.allCases) { mode in
                            Text(mode.rawValue).tag(mode)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.black.opacity(0.85))
                    .onChange(of: viewModel.scanMode) { newMode in
                        viewModel.switchScanMode(newMode)
                    }

                    // Main Content Area
                    if viewModel.scanMode == .liveCamera {
                        liveCameraSection
                    } else {
                        photoInspectionSection
                    }
                }
            }
            .navigationTitle("Shoot Scanner")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { viewModel.resetScan() }) {
                        Image(systemName: "arrow.counterclockwise")
                            .foregroundColor(.white)
                    }
                    .accessibilityLabel("Reset Scanner")
                    .accessibilityHint("Clears current leaf sample statistics and restarts scan")
                }
            }
            .onAppear {
                viewModel.onAppear()
            }
            .onDisappear {
                viewModel.onDisappear()
            }
        }
    }

    // MARK: - Live Camera Viewfinder

    private var liveCameraSection: some View {
        ZStack {
            if viewModel.hasCameraPermission {
                CameraPreviewView(session: viewModel.cameraService.captureSession)
                    .ignoresSafeArea(edges: .bottom)

                ScannerHudOverlayView(
                    fineLeafRatio: viewModel.smoothedFineLeafRatio > 0 ? viewModel.smoothedFineLeafRatio : viewModel.fineLeafRatio,
                    dominantStage: viewModel.assessment?.dominantStage,
                    qualityGrade: viewModel.qualityGrade,
                    meetsExportQuality: viewModel.isOptimalHarvest,
                    latencyMs: viewModel.inferenceTimeMs,
                    sampleCount: viewModel.frameSampleCount
                )

                // Bottom Floating Action Button
                VStack {
                    Spacer()
                    if let assessment = viewModel.assessment {
                        Button(action: {
                            onRecordWeighingTap?(assessment.fineLeafRatio)
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: "scalemass.fill")
                                Text("Log Weighing (\(assessment.formattedFinePercentage))")
                                    .fontWeight(.bold)
                            }
                            .font(.appHeadline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background(assessment.meetsExportQuality ? AppTheme.emerald : AppTheme.amber)
                            .cornerRadius(AppTheme.radiusMedium)
                            .shadow(color: Color.black.opacity(0.3), radius: 8, y: 4)
                            .padding(.horizontal, 20)
                            .padding(.bottom, 24)
                        }
                        .accessibilityLabel("Log Weighing with fine leaf ratio \(assessment.formattedFinePercentage)")
                        .accessibilityHint("Opens weighing entry form pre-filled with this quality grade")
                    }
                }
            } else {
                cameraPermissionDeniedView
            }
        }
    }

    // MARK: - Static Photo Inspection (PhotosUI & Samples)

    private var photoInspectionSection: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Photo Picker Header
                VStack(spacing: 12) {
                    PhotosPicker(selection: $selectedPickerItem, matching: .images) {
                        HStack(spacing: 8) {
                            Image(systemName: "photo.on.rectangle.angled")
                            Text("Select Shoot from Photo Library")
                                .fontWeight(.semibold)
                        }
                        .font(.appHeadline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(AppTheme.emerald)
                        .cornerRadius(AppTheme.radiusMedium)
                    }
                    .padding(.horizontal, 20)
                    .onChange(of: selectedPickerItem) { newItem in
                        Task {
                            if let data = try? await newItem?.loadTransferable(type: Data.self),
                               let image = UIImage(data: data) {
                                viewModel.analyzeSelectedImage(image)
                            }
                        }
                    }

                    // Sample Images for Simulator / Offline Testing
                    HStack(spacing: 10) {
                        Button(action: loadSampleFineShoot) {
                            HStack(spacing: 4) {
                                Image(systemName: "leaf.fill")
                                Text("Fine Shoot Sample")
                            }
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                            .foregroundColor(AppTheme.emeraldLight)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(8)
                        }

                        Button(action: loadSampleCoarseLeaf) {
                            HStack(spacing: 4) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                Text("Coarse Leaf Sample")
                            }
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                            .foregroundColor(AppTheme.amberLight)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(8)
                        }
                    }
                    .padding(.horizontal, 20)
                }
                .padding(.top, 16)

                // Image Preview Card
                if let image = viewModel.selectedImage {
                    VStack(spacing: 12) {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 260)
                            .cornerRadius(AppTheme.radiusMedium)
                            .overlay(
                                RoundedRectangle(cornerRadius: AppTheme.radiusMedium)
                                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
                            )
                            .padding(.horizontal, 20)

                        if viewModel.isAnalyzingPhoto {
                            ProgressView("Analyzing shoot with Neural Engine...")
                                .foregroundColor(.white)
                                .padding()
                        } else if let assessment = viewModel.assessment {
                            assessmentCard(assessment)
                        }
                    }
                } else {
                    emptyStateCard
                }
            }
            .padding(.bottom, 32)
        }
        .background(Color.black.ignoresSafeArea())
    }

    // MARK: - Assessment Details Card

    private func assessmentCard(_ assessment: LeafQualityAssessment) -> some View {
        VStack(spacing: 16) {
            // Quality Grade Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(assessment.qualityGrade)
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(assessment.meetsExportQuality ? AppTheme.emeraldLight : AppTheme.amberLight)

                    Text(assessment.actionRecommendation)
                        .font(.system(size: 12, weight: .regular, design: .rounded))
                        .foregroundColor(.white.opacity(0.8))
                }
                Spacer()
                Text(assessment.formattedFinePercentage)
                    .font(.system(size: 32, weight: .heavy, design: .rounded))
                    .foregroundColor(assessment.meetsExportQuality ? AppTheme.emeraldLight : AppTheme.amberLight)
            }
            .padding()
            .background(Color.white.opacity(0.08))
            .cornerRadius(12)

            // Maturity Stage Breakdown
            VStack(alignment: .leading, spacing: 10) {
                Text("Maturity Age Composition")
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundColor(.white.opacity(0.7))

                ForEach(LeafMaturityStage.allCases, id: \.self) { stage in
                    let prob = assessment.maturityProbabilities[stage.rawValue] ?? 0.0
                    maturityRow(stage: stage, probability: prob)
                }
            }
            .padding()
            .background(Color.white.opacity(0.06))
            .cornerRadius(12)

            // Latency Telemetry
            HStack {
                Label(assessment.formattedLatency, systemImage: "bolt.fill")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.6))
                Spacer()
                Label("Apple Neural Engine", systemImage: "cpu.fill")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.6))
            }
            .padding(.horizontal, 4)

            // Apply Button
            if let onRecordWeighingTap = onRecordWeighingTap {
                Button(action: {
                    onRecordWeighingTap(assessment.fineLeafRatio)
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "scalemass.fill")
                        Text("Apply to Harvest Weighing Sheet")
                            .fontWeight(.bold)
                    }
                    .font(.appHeadline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(assessment.meetsExportQuality ? AppTheme.emerald : AppTheme.amber)
                    .cornerRadius(AppTheme.radiusMedium)
                }
            }
        }
        .padding(.horizontal, 20)
    }

    private func maturityRow(stage: LeafMaturityStage, probability: Double) -> some View {
        VStack(spacing: 4) {
            HStack {
                Text(stage.displayTitle)
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundColor(.white)
                Spacer()
                Text(String(format: "%.1f%%", probability * 100.0))
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundColor(stage.isFineLeaf ? AppTheme.emeraldLight : .white.opacity(0.7))
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.white.opacity(0.15))
                        .frame(height: 6)
                    Capsule()
                        .fill(stage.isFineLeaf ? AppTheme.emeraldLight : AppTheme.crimsonLight)
                        .frame(width: max(geo.size.width * CGFloat(probability), 0), height: 6)
                }
            }
            .frame(height: 6)
        }
    }

    // MARK: - Empty & Error States

    private var emptyStateCard: some View {
        VStack(spacing: 12) {
            Image(systemName: "photo.badge.plus")
                .font(.system(size: 48, weight: .light))
                .foregroundColor(.white.opacity(0.4))
                .padding(.top, 40)

            Text("No Photograph Selected")
                .font(.appHeadline)
                .foregroundColor(.white)

            Text("Select an image from your device library or tap a sample shoot above to inspect leaf quality 100% offline.")
                .font(.appFootnote)
                .foregroundColor(.white.opacity(0.6))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
                .padding(.bottom, 40)
        }
        .frame(maxWidth: .infinity)
        .background(Color.white.opacity(0.04))
        .cornerRadius(AppTheme.radiusLarge)
        .padding(.horizontal, 20)
    }

    private var cameraPermissionDeniedView: some View {
        VStack(spacing: 16) {
            Image(systemName: "camera.fill")
                .font(.system(size: 48))
                .foregroundColor(AppTheme.amber)

            Text("Camera Access Required")
                .font(.appTitle)
                .foregroundColor(.white)

            Text("TeaYield AI requires camera permission to scan tea shoots at 60fps in field weighing sheds.")
                .font(.appBody)
                .foregroundColor(.white.opacity(0.7))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            Button("Switch to Photo Inspection Mode") {
                viewModel.switchScanMode(.photoLibrary)
            }
            .buttonStyle(.borderedProminent)
            .tint(AppTheme.emerald)
        }
        .padding()
    }

    // MARK: - Sample Helpers

    private func loadSampleFineShoot() {
        if let url = Bundle.main.url(forResource: "sample_fine_shoot", withExtension: "jpg"),
           let data = try? Data(contentsOf: url),
           let img = UIImage(data: data) {
            viewModel.analyzeSelectedImage(img)
        }
    }

    private func loadSampleCoarseLeaf() {
        if let url = Bundle.main.url(forResource: "sample_coarse_leaf", withExtension: "jpg"),
           let data = try? Data(contentsOf: url),
           let img = UIImage(data: data) {
            viewModel.analyzeSelectedImage(img)
        }
    }
}
