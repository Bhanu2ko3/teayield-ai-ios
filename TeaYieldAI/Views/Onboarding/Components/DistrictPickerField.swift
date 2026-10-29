import SwiftUI

/// Agro-ecological tea growing zones in Sri Lanka with elevation classifications.
enum SriLankanTeaDistrict: String, CaseIterable, Identifiable {
    case nuwaraEliya = "Nuwara Eliya"
    case badulla = "Badulla"
    case kandy = "Kandy"
    case matale = "Matale"
    case ratnapura = "Ratnapura"
    case kegalle = "Kegalle"
    case galle = "Galle"
    case matara = "Matara"

    var id: String { rawValue }

    var elevationCategory: String {
        switch self {
        case .nuwaraEliya:
            return "High-Grown (1,800m+)"
        case .badulla:
            return "Uva / High-to-Mid (1,000m - 1,800m)"
        case .kandy, .matale:
            return "Mid-Grown (600m - 1,200m)"
        case .ratnapura, .kegalle:
            return "Low-Grown Sabaragamuwa (< 600m)"
        case .galle, .matara:
            return "Low-Grown Southern (< 600m)"
        }
    }

    var defaultElevationMeters: Int {
        switch self {
        case .nuwaraEliya: return 1868
        case .badulla: return 1280
        case .kandy: return 650
        case .matale: return 540
        case .ratnapura: return 130
        case .kegalle: return 180
        case .galle: return 40
        case .matara: return 35
        }
    }
}

/// A dedicated form picker field presenting authorized Sri Lankan tea cultivation districts.
struct DistrictPickerField: View {

    @Binding var selectedDistrict: String
    var onDistrictChanged: ((SriLankanTeaDistrict) -> Void)?

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Agro-Ecological District")
                .font(.appCaption)
                .fontWeight(.medium)
                .foregroundColor(.secondary)

            Menu {
                ForEach(SriLankanTeaDistrict.allCases) { district in
                    Button {
                        selectedDistrict = district.rawValue
                        onDistrictChanged?(district)
                    } label: {
                        HStack {
                            Text(district.rawValue)
                            Spacer()
                            Text(district.elevationCategory)
                        }
                    }
                }
            } label: {
                HStack {
                    Image(systemName: "map.fill")
                        .foregroundColor(AppTheme.emerald)
                        .frame(width: 20)

                    Text(selectedDistrict)
                        .foregroundColor(.primary)
                        .font(.appBody)

                    Spacer()

                    if let matched = SriLankanTeaDistrict(rawValue: selectedDistrict) {
                        Text(matched.elevationCategory)
                            .font(.system(size: 11, weight: .medium, design: .rounded))
                            .foregroundColor(.secondary)
                    }

                    Image(systemName: "chevron.up.chevron.down")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
                .padding(14)
                .background(Color(uiColor: .tertiarySystemGroupedBackground))
                .cornerRadius(12)
            }
            .accessibilityLabel("Agro-Ecological District: currently \(selectedDistrict)")
            .accessibilityHint("Double tap to select from Sri Lankan tea cultivation zones")
        }
    }
}
