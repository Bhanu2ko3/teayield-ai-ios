import SwiftUI

/// Declarative HUD overlay displaying viewfinder reticle brackets, telemetry badges, and live quality gauges.
struct ScannerHudOverlayView: View {

    let fineLeafRatio: Double
    let dominantStage: LeafMaturityStage?
    let qualityGrade: String
    let meetsExportQuality: Bool
    let latencyMs: Double
    let sampleCount: Int

    var body: some View {
        VStack(spacing: 0) {
            // Top telemetry bar
            HStack(spacing: 8) {
                telemetryPill(icon: "bolt.fill", title: String(format: "%.1f ms", latencyMs))
                telemetryPill(icon: "camera.filters", title: "Samples: \(sampleCount)")
                Spacer()
                telemetryPill(icon: "cpu.fill", title: "Neural Engine")
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)

            Spacer()

            // Viewfinder reticle with targeting corner brackets
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .stroke(reticleColor.opacity(0.4), lineWidth: 1.5)
                    .frame(width: 260, height: 260)

                // 4 Corner targeting brackets
                ReticleBracketShape()
                    .stroke(reticleColor, style: StrokeStyle(lineWidth: 3.5, lineCap: .round))
                    .frame(width: 270, height: 270)

                // Central crosshair dot
                Circle()
                    .fill(reticleColor.opacity(0.8))
                    .frame(width: 6, height: 6)

                // Dominant stage pill inside reticle
                if let stage = dominantStage {
                    VStack {
                        Spacer()
                        Text(stage.displayTitle)
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.black.opacity(0.65))
                            .cornerRadius(12)
                            .padding(.bottom, 12)
                    }
                    .frame(width: 260, height: 260)
                }
            }

            Spacer()

            // Bottom live quality telemetry banner
            VStack(spacing: 8) {
                HStack {
                    VStack(alignment: .leading, spacing: 3) {
                        HStack(spacing: 6) {
                            Circle()
                                .fill(reticleColor)
                                .frame(width: 8, height: 8)
                            Text(qualityGrade)
                                .font(.system(size: 13, weight: .bold, design: .rounded))
                                .foregroundColor(reticleColor)
                        }

                        Text("Fine Leaf Export Standard (85%)")
                            .font(.system(size: 11, weight: .medium, design: .rounded))
                            .foregroundColor(.white.opacity(0.85))
                    }

                    Spacer()

                    Text(sampleCount == 0 ? "READY" : String(format: "%.1f%%", fineLeafRatio * 100.0))
                        .font(.system(size: sampleCount == 0 ? 20 : 26, weight: .heavy, design: .rounded))
                        .foregroundColor(reticleColor)
                }

                // Progress Bar with 85% target marker
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.white.opacity(0.2))
                            .frame(height: 8)

                        Capsule()
                            .fill(reticleColor)
                            .frame(width: max(geo.size.width * CGFloat(fineLeafRatio), 0), height: 8)

                        // 85% Benchmark threshold line
                        Rectangle()
                            .fill(Color.white)
                            .frame(width: 2, height: 14)
                            .offset(x: geo.size.width * 0.85 - 1)
                    }
                }
                .frame(height: 14)
            }
            .padding(14)
            .background(Color.black.opacity(0.7))
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(reticleColor.opacity(0.4), lineWidth: 1.2)
            )
            .shadow(color: Color.black.opacity(0.3), radius: 8, y: 4)
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Quality grade: \(qualityGrade), fine leaf ratio: \(String(format: "%.1f percent", fineLeafRatio * 100.0)), export benchmark: 85 percent, dominant stage: \(dominantStage?.displayTitle ?? "scanning"), latency: \(String(format: "%.1f milliseconds", latencyMs))")
        }
        .accessibilityElement(children: .contain)
    }

    private var reticleColor: Color {
        if sampleCount == 0 || dominantStage == nil {
            return AppTheme.emeraldLight
        } else if fineLeafRatio >= AppConfiguration.fineLeafTargetRatio {
            return AppTheme.emeraldLight
        } else if fineLeafRatio >= 0.70 {
            return AppTheme.amberLight
        } else {
            return AppTheme.crimsonLight
        }
    }

    private func telemetryPill(icon: String, title: String) -> some View {
        HStack(spacing: 5) {
            Image(systemName: icon)
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(AppTheme.emeraldLight)
            Text(title)
                .font(.system(size: 11, weight: .semibold, design: .rounded))
                .foregroundColor(.white)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(Color.black.opacity(0.55))
        .clipShape(Capsule())
        .overlay(
            Capsule()
                .stroke(Color.white.opacity(0.18), lineWidth: 0.8)
        )
    }
}

/// Custom shape drawing the four corner brackets of the camera reticle.
struct ReticleBracketShape: Shape {
    let bracketLength: CGFloat = 26

    func path(in rect: CGRect) -> Path {
        var path = Path()

        // Top Left
        path.move(to: CGPoint(x: rect.minX, y: rect.minY + bracketLength))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX + bracketLength, y: rect.minY))

        // Top Right
        path.move(to: CGPoint(x: rect.maxX - bracketLength, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY + bracketLength))

        // Bottom Right
        path.move(to: CGPoint(x: rect.maxX, y: rect.maxY - bracketLength))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX - bracketLength, y: rect.maxY))

        // Bottom Left
        path.move(to: CGPoint(x: rect.minX + bracketLength, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY - bracketLength))

        return path
    }
}

// MARK: - Previews

struct ScannerHudOverlayView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            ScannerHudOverlayView(
                fineLeafRatio: 0.88,
                dominantStage: .primeTwoLeaves,
                qualityGrade: "Export Grade A",
                meetsExportQuality: true,
                latencyMs: 16.5,
                sampleCount: 12
            )
        }
    }
}

