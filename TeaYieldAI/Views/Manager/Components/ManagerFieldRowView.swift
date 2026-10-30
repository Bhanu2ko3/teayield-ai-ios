import SwiftUI

/// Card row rendering individual estate tea field divisions with NDVI index and harvest readiness.
/// Conforms to industrial agronomic design principles and Apple HIG.
struct ManagerFieldRowView: View {

    let field: TeaField
    var onEdit: (() -> Void)? = nil
    var onDelete: (() -> Void)? = nil

    var body: some View {
        HStack(spacing: 12) {
            // Visual Block Indicator with Agronomic Leaf Accent
            ZStack {
                RoundedRectangle(cornerRadius: AppTheme.radiusSmall)
                    .fill(statusColor(for: field.status).opacity(0.12))
                    .frame(width: 44, height: 44)

                Image(systemName: "leaf.fill")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(statusColor(for: field.status))
            }

            // Division Name & Field Metadata
            VStack(alignment: .leading, spacing: 4) {
                Text(field.name)
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)

                HStack(spacing: 6) {
                    Text(field.blockCode)
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.primary.opacity(0.05))
                        .cornerRadius(AppTheme.radiusSmall)

                    Text("•")
                        .font(.caption2)
                        .foregroundColor(.secondary)

                    HStack(spacing: 3) {
                        Image(systemName: "square.dashed")
                            .font(.system(size: 10))
                        Text(field.formattedAcreage)
                            .font(.system(size: 11, weight: .medium, design: .rounded))
                    }
                    .foregroundColor(.secondary)
                }
            }

            Spacer()

            // NDVI Score, Readiness Badge & Context Menu
            VStack(alignment: .trailing, spacing: 4) {
                HStack(spacing: 6) {
                    Text(field.status.rawValue)
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .foregroundColor(statusColor(for: field.status))
                        .padding(.horizontal, 7)
                        .padding(.vertical, 3)
                        .background(statusColor(for: field.status).opacity(0.12))
                        .cornerRadius(AppTheme.radiusSmall)

                    if onEdit != nil || onDelete != nil {
                        Menu {
                            if let onEdit = onEdit {
                                Button {
                                    onEdit()
                                } label: {
                                    Label("Edit Block", systemImage: "pencil")
                                }
                            }

                            if let onDelete = onDelete {
                                Divider()
                                Button(role: .destructive) {
                                    onDelete()
                                } label: {
                                    Label("Retire Division", systemImage: "trash")
                                }
                            }
                        } label: {
                            Image(systemName: "ellipsis.circle")
                                .font(.system(size: 18))
                                .foregroundColor(.secondary)
                                .padding(2)
                        }
                    }
                }

                HStack(spacing: 4) {
                    Text("NDVI")
                        .font(.system(size: 9, weight: .bold, design: .rounded))
                        .foregroundColor(.secondary)

                    Text(field.formattedNDVI)
                        .font(.system(size: 12, weight: .bold, design: .monospaced))
                        .foregroundColor(statusColor(for: field.status))
                }
            }
        }
        .padding(12)
        .teaYieldCard(cornerRadius: AppTheme.radiusMedium)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(field.name), Block \(field.blockCode), Acreage \(field.formattedAcreage), Readiness Status \(field.status.rawValue), NDVI score \(field.formattedNDVI)")
    }

    private func statusColor(for status: FieldReadinessStatus) -> Color {
        switch status {
        case .ready: return AppTheme.emerald
        case .growing: return AppTheme.amber
        case .resting: return AppTheme.crimson
        }
    }
}

// MARK: - Previews

struct ManagerFieldRowView_Previews: PreviewProvider {
    static var previews: some View {
        ManagerFieldRowView(field: MockData.fieldBlockA)
            .padding()
            .previewLayout(.sizeThatFits)
    }
}

