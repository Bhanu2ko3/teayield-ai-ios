import SwiftUI
import PhotosUI

/// Real-time on-device tea shoot quality scanner and inspection suite (Component 3).
/// Supports live 60fps camera viewfinder scanning and PhotosUI static image analysis.
struct LeafScannerView: View {

    @StateObject private var viewModel: LeafScannerViewModel
    var onRecordWeighingTap: ((Double) -> Void)?

    @State private var selectedPickerItem: PhotosPickerItem?
    @State private var showingDetailSheet = false
    @Environment(\.colorScheme) private var colorScheme

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
                // Adaptive root surface matching active inspection mode and system theme
                (viewModel.scanMode == .liveCamera ? Color.black : AppTheme.backgroundGrouped)
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    topHeaderBar
                        .padding(.horizontal, 20)
                        .padding(.top, 12)
                        .padding(.bottom, 8)
                        .background(viewModel.scanMode == .liveCamera ? Color.black : Color(uiColor: .systemGroupedBackground))

                    // Top Mode Selector with full theme contrast support
                    modeSelectorBar

                    // Main Content Area
                    if viewModel.scanMode == .liveCamera {
                        liveCameraSection
                    } else {
                        photoInspectionSection
                    }
                }
            }
            .navigationBarHidden(true)
            .onAppear {
                viewModel.onAppear()
            }
            .onDisappear {
                viewModel.onDisappear()
            }
            .applyAppTheme()
        }
    }

    // MARK: - Top Header Bar

    private var topHeaderBar: some View {
        HStack(spacing: 10) {
            Text("Shoot Scanner")
                .font(.appHeadline)
                .fontWeight(.bold)
                .foregroundColor(viewModel.scanMode == .liveCamera ? .white : .primary)

            Spacer()

            Button(action: {
                HapticFeedback.lightImpact()
                viewModel.resetScan()
            }) {
                Image(systemName: "arrow.counterclockwise")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(AppTheme.emerald)
                    .frame(width: 36, height: 36)
                    .background(viewModel.scanMode == .liveCamera ? Color.white.opacity(0.15) : Color.secondary.opacity(0.12))
                    .clipShape(Circle())
            }
            .accessibilityLabel("Reset Scanner")
            .accessibilityHint("Clears current leaf sample statistics and restarts scan")
        }
    }

    // MARK: - Top Mode Selector Bar

    private var modeSelectorBar: some View {
        HStack(spacing: 6) {
            ForEach(LeafScanMode.allCases) { mode in
                Button {
                    HapticFeedback.selection()
                    withAnimation(.easeInOut(duration: 0.2)) {
                        viewModel.switchScanMode(mode)
                    }
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: mode == .liveCamera ? "viewfinder" : "photo.on.rectangle")
                            .font(.system(size: 12, weight: .semibold))
                        Text(mode == .liveCamera ? "Live Camera" : "Photo Gallery")
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                            .lineLimit(1)
                            .minimumScaleFactor(0.85)
                    }
                    .foregroundColor(
                        viewModel.scanMode == mode
                            ? .white
                            : (viewModel.scanMode == .liveCamera ? .white.opacity(0.85) : .primary)
                    )
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(
                        Group {
                            if viewModel.scanMode == mode {
                                RoundedRectangle(cornerRadius: AppTheme.radiusMedium - 2)
                                    .fill(AppTheme.emerald)
                                    .shadow(color: AppTheme.emerald.opacity(0.35), radius: 4, y: 2)
                            } else {
                                Color.clear
                            }
                        }
                    )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(4)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.radiusMedium)
                .fill(
                    viewModel.scanMode == .liveCamera
                        ? Color(white: 0.18)
                        : (colorScheme == .dark ? Color(uiColor: .secondarySystemGroupedBackground) : Color.white)
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.radiusMedium)
                .stroke(
                    viewModel.scanMode == .liveCamera
                        ? Color.white.opacity(0.15)
                        : AppTheme.borderSubtle,
                    lineWidth: 1
                )
        )
        .shadow(
            color: Color.black.opacity(colorScheme == .dark ? 0.3 : 0.05),
            radius: 6,
            y: 2
        )
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(
            viewModel.scanMode == .liveCamera
                ? Color.black
                : AppTheme.backgroundGrouped
        )
    }

    // MARK: - Live Camera Viewfinder

    private var liveCameraSection: some View {
        ZStack {
            if viewModel.hasCameraPermission {
                #if targetEnvironment(simulator)
                simulatorViewfinderBackdrop
                #else
                CameraPreviewView(session: viewModel.cameraService.captureSession)
                    .ignoresSafeArea(edges: .bottom)
                #endif

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
                            HapticFeedback.mediumImpact()
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
                            .padding(.bottom, 90)
                        }
                        .accessibilityLabel("Log Weighing with fine leaf ratio \(assessment.formattedFinePercentage)")
                        .accessibilityHint("Opens weighing entry form pre-filled with this quality grade")
                    }
                }
            } else {
                cameraPermissionDeniedView
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        #if targetEnvironment(simulator)
        .contentShape(Rectangle())
        .onTapGesture {
            if viewModel.assessment == nil {
                HapticFeedback.lightImpact()
                loadSampleFineShoot()
            }
        }
        #endif
    }

    // MARK: - Simulator Fallback Viewfinder

    private var simulatorViewfinderBackdrop: some View {
        GeometryReader { geo in
            ZStack {
                if let simImage = loadSimulatorBackdropImage() {
                    Image(uiImage: simImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: geo.size.width, height: geo.size.height)
                        .clipped()
                        .overlay(Color.black.opacity(0.30))
                } else {
                    LinearGradient(
                        colors: [
                            AppTheme.forest,
                            AppTheme.navyDark
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .frame(width: geo.size.width, height: geo.size.height)
                }

                // Agritech Viewfinder 3x3 Grid
                cameraGridLines
            }
        }
        .ignoresSafeArea(edges: .bottom)
    }

    private var cameraGridLines: some View {
        GeometryReader { geo in
            Path { path in
                let w = geo.size.width
                let h = geo.size.height
                // 2 vertical lines
                path.move(to: CGPoint(x: w / 3, y: 0))
                path.addLine(to: CGPoint(x: w / 3, y: h))
                path.move(to: CGPoint(x: 2 * w / 3, y: 0))
                path.addLine(to: CGPoint(x: 2 * w / 3, y: h))

                // 2 horizontal lines
                path.move(to: CGPoint(x: 0, y: h / 3))
                path.addLine(to: CGPoint(x: w, y: h / 3))
                path.move(to: CGPoint(x: 0, y: 2 * h / 3))
                path.addLine(to: CGPoint(x: w, y: 2 * h / 3))
            }
            .stroke(Color.white.opacity(0.12), lineWidth: 0.8)
        }
    }

    // MARK: - Static Photo Inspection (PhotosUI & Samples)

    private var photoInspectionSection: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Photo Picker Header
                PhotosPicker(selection: $selectedPickerItem, matching: .images) {
                    HStack(spacing: 8) {
                        Image(systemName: "photo.on.rectangle.angled")
                        Text("Select Shoot from Photo Library")
                            .fontWeight(.semibold)
                    }
                    .font(.appHeadline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(AppTheme.emerald)
                    .cornerRadius(AppTheme.radiusMedium)
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .onChange(of: selectedPickerItem) { newItem in
                    Task {
                        if let data = try? await newItem?.loadTransferable(type: Data.self),
                           let image = UIImage(data: data) {
                            viewModel.analyzeSelectedImage(image)
                        }
                    }
                }

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
                                    .stroke(AppTheme.borderSubtle, lineWidth: 1)
                            )
                            .padding(.horizontal, 20)

                        if viewModel.isAnalyzingPhoto {
                            ProgressView("Analyzing shoot with Neural Engine...")
                                .foregroundColor(.primary)
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
        .background(AppTheme.backgroundGrouped.ignoresSafeArea())
    }

    // MARK: - Assessment Details Card

    private func assessmentCard(_ assessment: LeafQualityAssessment) -> some View {
        VStack(spacing: 16) {
            // Quality Grade Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(assessment.qualityGrade)
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(assessment.meetsExportQuality ? AppTheme.emerald : AppTheme.amber)

                    Text(assessment.actionRecommendation)
                        .font(.system(size: 12, weight: .regular, design: .rounded))
                        .foregroundColor(.secondary)
                }
                Spacer()
                Text(assessment.formattedFinePercentage)
                    .font(.system(size: 32, weight: .heavy, design: .rounded))
                    .foregroundColor(assessment.meetsExportQuality ? AppTheme.emerald : AppTheme.amber)
            }
            .padding()
            .teaYieldCard(cornerRadius: AppTheme.radiusMedium)

            // Maturity Stage Breakdown
            VStack(alignment: .leading, spacing: 10) {
                Text("Maturity Age Composition")
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundColor(.primary)

                ForEach(LeafMaturityStage.allCases, id: \.self) { stage in
                    let prob = assessment.maturityProbabilities[stage.rawValue] ?? 0.0
                    maturityRow(stage: stage, probability: prob)
                }
            }
            .padding()
            .teaYieldCard(cornerRadius: AppTheme.radiusMedium)

            // Latency Telemetry
            HStack {
                Label(assessment.formattedLatency, systemImage: "bolt.fill")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(.secondary)
                Spacer()
                Label("Apple Neural Engine", systemImage: "cpu.fill")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 4)

            // Apply Button
            if let onRecordWeighingTap = onRecordWeighingTap {
                TeaYieldButton(
                    title: "Apply to Harvest Weighing Sheet",
                    icon: "scalemass.fill",
                    style: assessment.meetsExportQuality ? .primary : .tonal,
                    action: {
                        onRecordWeighingTap(assessment.fineLeafRatio)
                    }
                )
            }
        }
        .padding(.horizontal, 20)
    }

    private func maturityRow(stage: LeafMaturityStage, probability: Double) -> some View {
        VStack(spacing: 4) {
            HStack {
                Text(stage.displayTitle)
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundColor(.primary)
                Spacer()
                Text(String(format: "%.1f%%", probability * 100.0))
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundColor(stage.isFineLeaf ? AppTheme.emerald : .secondary)
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.primary.opacity(0.08))
                        .frame(height: 6)
                    Capsule()
                        .fill(stage.isFineLeaf ? AppTheme.emerald : AppTheme.crimson)
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
                .foregroundColor(AppTheme.emerald.opacity(0.6))
                .padding(.top, 40)

            Text("No Photograph Selected")
                .font(.appHeadline)
                .foregroundColor(.primary)

            Text("Select a tea shoot photograph from your photo library to inspect fine leaf quality ratio (Two Leaves and a Bud benchmark) offline.")
                .font(.appFootnote)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
                .padding(.bottom, 40)
        }
        .frame(maxWidth: .infinity)
        .teaYieldCard(cornerRadius: AppTheme.radiusLarge)
        .padding(.horizontal, 20)
    }

    private var cameraPermissionDeniedView: some View {
        VStack(spacing: 16) {
            Image(systemName: "camera.fill")
                .font(.system(size: 48))
                .foregroundColor(AppTheme.amber)

            Text("Camera Access Required")
                .font(.appTitle)
                .foregroundColor(.primary)

            Text("TeaYield AI requires camera permission to scan tea shoots at 60fps in field weighing sheds.")
                .font(.appBody)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            Button("Switch to Photo Inspection Mode") {
                viewModel.switchScanMode(.photoLibrary)
            }
            .buttonStyle(.borderedProminent)
            .tint(AppTheme.emerald)
        }
        .padding()
        .teaYieldCard(cornerRadius: AppTheme.radiusLarge)
        .padding(.horizontal, 20)
    }

    // MARK: - Sample Helpers

    private func loadSimulatorBackdropImage() -> UIImage? {
        if let url = Bundle.main.url(forResource: "sample_fine_shoot", withExtension: "jpg"),
           let data = try? Data(contentsOf: url),
           let img = UIImage(data: data) {
            return img
        }
        return UIImage(named: "sample_fine_shoot")
    }

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

// MARK: - Previews

struct LeafScannerView_Previews: PreviewProvider {
    static var previews: some View {
        LeafScannerView(
            viewModel: LeafScannerViewModel(
                cameraService: AppContainer.shared.cameraService,
                classifier: AppContainer.shared.leafClassifier
            )
        )
    }
}

