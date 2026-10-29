import SwiftUI

/// Administrative districts of Sri Lanka with agro-ecological tea zone and elevation classifications.
enum SriLankanTeaDistrict: String, CaseIterable, Identifiable {
    // Primary Tea Cultivating Districts (High, Mid, Low & Uva zones)
    case nuwaraEliya = "Nuwara Eliya"
    case badulla = "Badulla"
    case kandy = "Kandy"
    case matale = "Matale"
    case ratnapura = "Ratnapura"
    case kegalle = "Kegalle"
    case galle = "Galle"
    case matara = "Matara"
    case kalutara = "Kalutara"
    case hambantota = "Hambantota"
    case monaragala = "Monaragala"
    case kurunegala = "Kurunegala"

    // Other Administrative Districts across Sri Lanka
    case colombo = "Colombo"
    case gampaha = "Gampaha"
    case ampara = "Ampara"
    case anuradhapura = "Anuradhapura"
    case batticaloa = "Batticaloa"
    case jaffna = "Jaffna"
    case kilinochchi = "Kilinochchi"
    case mannar = "Mannar"
    case mullaitivu = "Mullaitivu"
    case polonnaruwa = "Polonnaruwa"
    case puttalam = "Puttalam"
    case trincomalee = "Trincomalee"
    case vavuniya = "Vavuniya"

    var id: String { rawValue }

    var isTeaCultivationDistrict: Bool {
        switch self {
        case .nuwaraEliya, .badulla, .kandy, .matale,
             .ratnapura, .kegalle, .galle, .matara,
             .kalutara, .hambantota, .monaragala, .kurunegala:
            return true
        default:
            return false
        }
    }

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
        case .kalutara:
            return "Low-Grown Western (< 600m)"
        case .hambantota:
            return "Low-Grown Ruhuna (< 600m)"
        case .monaragala:
            return "Uva Lowlands (< 600m)"
        case .kurunegala:
            return "North Western Mid-to-Low (< 600m)"
        case .colombo, .gampaha:
            return "Western Lowlands (< 100m)"
        case .puttalam:
            return "North Western Lowlands (< 100m)"
        case .anuradhapura, .polonnaruwa:
            return "North Central Lowlands (< 150m)"
        case .ampara, .batticaloa, .trincomalee:
            return "Eastern Lowlands (< 100m)"
        case .jaffna, .kilinochchi, .mannar, .vavuniya, .mullaitivu:
            return "Northern Lowlands (< 100m)"
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
        case .kalutara: return 30
        case .hambantota: return 25
        case .monaragala: return 200
        case .kurunegala: return 120
        case .colombo: return 15
        case .gampaha: return 20
        case .puttalam: return 20
        case .anuradhapura: return 90
        case .polonnaruwa: return 60
        case .ampara: return 35
        case .batticaloa: return 10
        case .trincomalee: return 15
        case .jaffna: return 10
        case .kilinochchi: return 20
        case .mannar: return 10
        case .vavuniya: return 100
        case .mullaitivu: return 15
        }
    }

    /// Major commercial tea growing districts in Sri Lanka
    static var teaDistricts: [SriLankanTeaDistrict] {
        allCases.filter { $0.isTeaCultivationDistrict }
    }

    /// Other administrative districts across Sri Lanka
    static var otherDistricts: [SriLankanTeaDistrict] {
        allCases.filter { !$0.isTeaCultivationDistrict }
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
                Section("Tea Cultivation Districts") {
                    ForEach(SriLankanTeaDistrict.teaDistricts) { district in
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
                }

                Section("Other Administrative Districts") {
                    ForEach(SriLankanTeaDistrict.otherDistricts) { district in
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
                }
            } label: {
                HStack {
                    Image(systemName: "map.fill")
                        .foregroundColor(selectedDistrict.isEmpty ? .secondary : AppTheme.emerald)
                        .frame(width: 20)

                    if selectedDistrict.isEmpty {
                        Text("Select District")
                            .foregroundColor(.secondary)
                            .font(.appBody)
                    } else {
                        Text(selectedDistrict)
                            .foregroundColor(.primary)
                            .font(.appBody)
                    }

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
                .cornerRadius(AppTheme.radiusMedium)
            }
            .accessibilityLabel("Agro-Ecological District: \(selectedDistrict.isEmpty ? "Not selected" : selectedDistrict)")
            .accessibilityHint("Double tap to choose from Sri Lankan districts")
        }
    }
}

// MARK: - Previews

struct DistrictPickerField_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 16) {
            DistrictPickerField(selectedDistrict: .constant(""))
            DistrictPickerField(selectedDistrict: .constant("Nuwara Eliya"))
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}


