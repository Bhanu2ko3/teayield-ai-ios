import SwiftUI

/// Placeholder view for MapKit spatial GIS vector polygons and background geofencing (Component 3).
struct FieldMapPlaceholderView: View {

    var body: some View {
        NavigationStack {
            ZStack {
                Color(uiColor: .systemGroupedBackground)
                    .ignoresSafeArea()

                VStack(spacing: 24) {
                    Spacer()

                    ZStack {
                        Circle()
                            .fill(Color.blue.opacity(0.12))
                            .frame(width: 120, height: 120)

                        Image(systemName: "map.fill")
                            .font(.system(size: 52))
                            .foregroundColor(.blue)
                    }

                    VStack(spacing: 8) {
                        Text("Spatial Field GIS & Geofencing")
                            .font(.appTitle)
                            .foregroundColor(.primary)

                        Text("MapKit Polygons • CoreLocation Monitoring")
                            .font(.appCallout)
                            .foregroundColor(.blue)
                            .fontWeight(.semibold)

                        Text("Interactive vector overlays color-coded by Sentinel-2 NDVI health alongside low-power background circular region alerts for estate divisions.")
                            .font(.appBody)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                            .lineSpacing(3)
                    }

                    VStack(spacing: 10) {
                        mapDivisionCard(name: "Division Block A", acreage: "12.5 Ac", status: "READY (0.82)", color: AppTheme.emerald)
                        mapDivisionCard(name: "Division Block B", acreage: "15.0 Ac", status: "GROWING (0.74)", color: AppTheme.amber)
                        mapDivisionCard(name: "Division Block C", acreage: "9.8 Ac", status: "RESTING (0.58)", color: AppTheme.crimson)
                    }
                    .padding(.horizontal, 24)

                    Spacer()
                }
            }
            .navigationTitle("Field Map")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private func mapDivisionCard(name: String, acreage: String, status: String, color: Color) -> some View {
        HStack {
            Circle()
                .fill(color)
                .frame(width: 10, height: 10)

            VStack(alignment: .leading, spacing: 2) {
                Text(name)
                    .font(.appHeadline)
                    .foregroundColor(.primary)

                Text("Acreage: \(acreage)")
                    .font(.appCaption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Text(status)
                .font(.appBadge)
                .foregroundColor(color)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(color.opacity(0.12))
                .cornerRadius(6)
        }
        .padding(14)
        .teaYieldCard(cornerRadius: AppTheme.radiusMedium)
    }
}
