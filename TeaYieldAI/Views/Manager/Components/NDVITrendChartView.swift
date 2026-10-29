import SwiftUI
import Charts

/// Interactive Swift Charts visualization displaying Sentinel-2 multispectral NDVI vegetative canopy progression.
struct NDVITrendChartView: View {

    let data: [NDVITrendPoint]
    @State private var selectedPoint: NDVITrendPoint?

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            headerSection
            chartContainer
            if let selected = selectedPoint {
                selectedWeekInspectorCard(for: selected)
            }
        }
        .padding(16)
        .teaYieldCard(cornerRadius: AppTheme.radiusLarge)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Sentinel-2 NDVI Canopy Trend Chart: Latest NDVI \(latestNDVIFormatted)")
    }

    // MARK: - Subviews

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text("Sentinel-2 NDVI Canopy Trend")
                    .font(.appHeadline)
                    .foregroundColor(.primary)

                Spacer()

                HStack(spacing: 4) {
                    Circle()
                        .fill(AppTheme.emerald)
                        .frame(width: 8, height: 8)
                    Text("Canopy Vigor")
                        .font(.system(size: 10, weight: .semibold, design: .rounded))
                        .foregroundColor(.secondary)
                }
            }

            Text("Multi-spectral chlorophyll reflectance (B8 NIR / B4 Red) over 8-week cycle")
                .font(.appCaption)
                .foregroundColor(.secondary)
        }
    }

    private var chartContainer: some View {
        Chart {
            ForEach(data) { point in
                AreaMark(
                    x: .value("Week", point.weekLabel),
                    y: .value("NDVI", point.ndviScore)
                )
                .foregroundStyle(
                    LinearGradient(
                        colors: [AppTheme.emerald.opacity(0.35), AppTheme.emerald.opacity(0.02)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .interpolationMethod(.monotone)

                LineMark(
                    x: .value("Week", point.weekLabel),
                    y: .value("NDVI", point.ndviScore)
                )
                .foregroundStyle(AppTheme.emerald)
                .lineStyle(StrokeStyle(lineWidth: 2.5, lineCap: .round, lineJoin: .round))
                .interpolationMethod(.monotone)

                PointMark(
                    x: .value("Week", point.weekLabel),
                    y: .value("NDVI", point.ndviScore)
                )
                .foregroundStyle(point.isHarvestReady ? AppTheme.emerald : AppTheme.amber)
                .symbolSize(selectedPoint?.id == point.id ? 70 : 35)
            }

            RuleMark(y: .value("Readiness Threshold", 0.75))
                .lineStyle(StrokeStyle(lineWidth: 1.5, dash: [4, 4]))
                .foregroundStyle(AppTheme.emerald.opacity(0.8))
                .annotation(position: .top, alignment: .leading) {
                    Text("Harvest Ready 0.75")
                        .font(.system(size: 9, weight: .bold, design: .rounded))
                        .foregroundColor(AppTheme.emerald)
                        .padding(.horizontal, 4)
                        .padding(.vertical, 2)
                        .background(Color(uiColor: .secondarySystemGroupedBackground).opacity(0.9))
                        .cornerRadius(4)
                }
        }
        .chartYScale(domain: 0.40...0.95)
        .chartYAxis {
            AxisMarks(position: .leading) { value in
                AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, dash: [2, 2]))
                AxisValueLabel {
                    if let doubleValue = value.as(Double.self) {
                        Text(String(format: "%.2f", doubleValue))
                            .font(.system(size: 10, design: .rounded))
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .chartXAxis {
            AxisMarks { value in
                AxisValueLabel {
                    if let stringValue = value.as(String.self) {
                        Text(stringValue)
                            .font(.system(size: 10, weight: .semibold, design: .rounded))
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .frame(height: 180)
        .chartOverlay { proxy in
            GeometryReader { geometry in
                Rectangle()
                    .fill(Color.clear)
                    .contentShape(Rectangle())
                    .gesture(
                        SpatialTapGesture()
                            .onEnded { location in
                                handleChartTap(at: location.location, proxy: proxy, geometry: geometry)
                            }
                    )
            }
        }
    }

    private func selectedWeekInspectorCard(for point: NDVITrendPoint) -> some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text(point.weekLabel)
                    .font(.appHeadline)
                    .foregroundColor(.primary)
                Text("Sentinel-2 Satellite Pass")
                    .font(.appCaption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text(String(format: "%.3f NDVI", point.ndviScore))
                    .font(.system(size: 14, weight: .heavy, design: .rounded))
                    .foregroundColor(point.isHarvestReady ? AppTheme.emerald : AppTheme.amber)
                Text(point.isHarvestReady ? "Harvest Window Open" : "Vegetative Growth Phase")
                    .font(.system(size: 10, weight: .semibold, design: .rounded))
                    .foregroundColor(.secondary)
            }
        }
        .padding(12)
        .background(Color(uiColor: .tertiarySystemGroupedBackground))
        .cornerRadius(AppTheme.radiusMedium)
        .transition(.opacity.combined(with: .scale(scale: 0.95)))
    }

    private func handleChartTap(at location: CGPoint, proxy: ChartProxy, geometry: GeometryProxy) {
        let plotFrame = geometry[proxy.plotAreaFrame]
        guard plotFrame.contains(location) else { return }
        let plotX = location.x - plotFrame.origin.x
        guard let xValue: String = proxy.value(atX: plotX) else { return }
        if let matched = data.first(where: { $0.weekLabel == xValue }) {
            withAnimation(.easeInOut(duration: 0.2)) {
                if selectedPoint?.id == matched.id {
                    selectedPoint = nil
                } else {
                    selectedPoint = matched
                    HapticFeedback.lightImpact()
                }
            }
        }
    }

    private var latestNDVIFormatted: String {
        guard let last = data.last else { return "0.00" }
        return String(format: "%.2f", last.ndviScore)
    }
}

// MARK: - Previews

struct NDVITrendChartView_Previews: PreviewProvider {
    static var previews: some View {
        NDVITrendChartView(data: [
            NDVITrendPoint(weekLabel: "Wk 1", weekIndex: 1, ndviScore: 0.65, targetThreshold: 0.75),
            NDVITrendPoint(weekLabel: "Wk 2", weekIndex: 2, ndviScore: 0.68, targetThreshold: 0.75),
            NDVITrendPoint(weekLabel: "Wk 3", weekIndex: 3, ndviScore: 0.72, targetThreshold: 0.75),
            NDVITrendPoint(weekLabel: "Wk 4", weekIndex: 4, ndviScore: 0.78, targetThreshold: 0.75)
        ])
        .padding()
        .previewLayout(.sizeThatFits)
    }
}

