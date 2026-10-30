import WidgetKit
import SwiftUI

// MARK: - Timeline Entry

struct HarvestTelemetryEntry: TimelineEntry {
    let date: Date
    let estateName: String
    let targetYieldKg: Double
    let harvestedKg: Double
    let readyFieldsCount: Int
    let fineLeafRatioPercent: Double
    let isOffline: Bool

    var progress: Double {
        guard targetYieldKg > 0 else { return 0 }
        return min(1.0, harvestedKg / targetYieldKg)
    }
}

// MARK: - Timeline Provider

struct TeaYieldTimelineProvider: TimelineProvider {
    typealias Entry = HarvestTelemetryEntry

    func placeholder(in context: Context) -> HarvestTelemetryEntry {
        HarvestTelemetryEntry(
            date: Date(),
            estateName: "Great Western Valley",
            targetYieldKg: 750,
            harvestedKg: 480,
            readyFieldsCount: 2,
            fineLeafRatioPercent: 88.5,
            isOffline: false
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (HarvestTelemetryEntry) -> Void) {
        let entry = HarvestTelemetryEntry(
            date: Date(),
            estateName: "Great Western Valley",
            targetYieldKg: 750,
            harvestedKg: 480,
            readyFieldsCount: 2,
            fineLeafRatioPercent: 88.5,
            isOffline: false
        )
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<HarvestTelemetryEntry>) -> Void) {
        // Read cached estate telemetry from shared App Group or defaults
        let userDefaults = UserDefaults(suiteName: "group.com.teayield.TeaYieldAI") ?? UserDefaults.standard

        let estate = userDefaults.string(forKey: "widget_estate_name") ?? "Great Western Valley"
        let target = userDefaults.double(forKey: "widget_target_kg") > 0 ? userDefaults.double(forKey: "widget_target_kg") : 750.0
        let harvested = userDefaults.double(forKey: "widget_harvested_kg") > 0 ? userDefaults.double(forKey: "widget_harvested_kg") : 520.0
        let readyCount = userDefaults.integer(forKey: "widget_ready_fields") > 0 ? userDefaults.integer(forKey: "widget_ready_fields") : 2
        let quality = userDefaults.double(forKey: "widget_quality_ratio") > 0 ? userDefaults.double(forKey: "widget_quality_ratio") : 89.2

        let currentEntry = HarvestTelemetryEntry(
            date: Date(),
            estateName: estate,
            targetYieldKg: target,
            harvestedKg: harvested,
            readyFieldsCount: readyCount,
            fineLeafRatioPercent: quality,
            isOffline: false
        )

        // Refresh hourly or on system schedule
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 30, to: Date()) ?? Date().addingTimeInterval(1800)
        let timeline = Timeline(entries: [currentEntry], policy: .after(nextUpdate))
        completion(timeline)
    }
}

// MARK: - Widget Entry View

struct TeaYieldAIWidgetEntryView: View {
    var entry: TeaYieldTimelineProvider.Entry
    @Environment(\.widgetFamily) var family

    private let emerald = Color(red: 0.063, green: 0.725, blue: 0.506)
    private let forest = Color(red: 0.039, green: 0.380, blue: 0.239)

    var body: some View {
        switch family {
        case .systemSmall:
            smallWidgetView
        default:
            mediumWidgetView
        }
    }

    // MARK: - Small Widget (Compact Circular Progress)

    private var smallWidgetView: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                HStack(spacing: 4) {
                    Image(systemName: "leaf.fill")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(emerald)
                    Text("TeaYield")
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                }
                Spacer()
                Text("\(Int(entry.progress * 100))%")
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundColor(emerald)
            }

            Spacer()

            ZStack(alignment: .center) {
                Circle()
                    .stroke(emerald.opacity(0.2), lineWidth: 7)
                    .frame(width: 58, height: 58)

                Circle()
                    .trim(from: 0.0, to: CGFloat(entry.progress))
                    .stroke(emerald, style: StrokeStyle(lineWidth: 7, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .frame(width: 58, height: 58)

                VStack(spacing: 0) {
                    Text(String(format: "%.0f", entry.harvestedKg))
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                    Text("kg")
                        .font(.system(size: 9, weight: .semibold, design: .rounded))
                        .foregroundColor(.secondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .center)

            Spacer()

            HStack {
                Text("\(entry.readyFieldsCount) Ready")
                    .font(.system(size: 10, weight: .semibold, design: .rounded))
                    .foregroundColor(emerald)
                Spacer()
                Text(String(format: "%.0f%% Q", entry.fineLeafRatioPercent))
                    .font(.system(size: 10, weight: .semibold, design: .rounded))
                    .foregroundColor(.secondary)
            }
        }
        .padding(12)
        .widgetBackground(Color(uiColor: .secondarySystemGroupedBackground))
    }

    // MARK: - Medium Widget (Telemetry Card)

    private var mediumWidgetView: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Header
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "leaf.fill")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(emerald)
                    Text("TeaYield AI")
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                }

                Spacer()

                Text(entry.estateName)
                    .font(.system(size: 10, weight: .medium, design: .rounded))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }

            Divider()

            // Details
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .stroke(emerald.opacity(0.18), lineWidth: 6)
                        .frame(width: 52, height: 52)

                    Circle()
                        .trim(from: 0.0, to: CGFloat(entry.progress))
                        .stroke(emerald, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                        .frame(width: 52, height: 52)

                    Text("\(Int(entry.progress * 100))%")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text("Today's Harvest Intake")
                        .font(.system(size: 11, weight: .semibold, design: .rounded))
                        .foregroundColor(.secondary)

                    HStack(alignment: .firstTextBaseline, spacing: 3) {
                        Text(String(format: "%.0f", entry.harvestedKg))
                            .font(.system(size: 19, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                        Text("/ \(String(format: "%.0f", entry.targetYieldKg)) kg")
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundColor(.secondary)
                    }

                    HStack(spacing: 10) {
                        HStack(spacing: 3) {
                            Circle()
                                .fill(emerald)
                                .frame(width: 6, height: 6)
                            Text("\(entry.readyFieldsCount) Ready Fields")
                                .font(.system(size: 10, weight: .semibold, design: .rounded))
                                .foregroundColor(emerald)
                        }

                        HStack(spacing: 3) {
                            Image(systemName: "checkmark.seal.fill")
                                .font(.system(size: 9))
                                .foregroundColor(forest)
                            Text(String(format: "%.1f%% Quality", entry.fineLeafRatioPercent))
                                .font(.system(size: 10, weight: .semibold, design: .rounded))
                                .foregroundColor(.secondary)
                        }
                    }
                }
                Spacer()
            }
        }
        .padding(14)
        .widgetBackground(Color(uiColor: .secondarySystemGroupedBackground))
    }
}

// MARK: - Safe Background Modifier for iOS 16 / 17

extension View {
    func widgetBackground(_ backgroundView: some View) -> some View {
        if #available(iOSApplicationExtension 17.0, *) {
            return containerBackground(for: .widget) {
                backgroundView
            }
        } else {
            return background(backgroundView)
        }
    }
}

// MARK: - Widget Configuration

@main
struct TeaYieldAIWidget: Widget {
    let kind: String = "TeaYieldAIWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: TeaYieldTimelineProvider()) { entry in
            TeaYieldAIWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("TeaYield Daily Intake")
        .description("Live Ceylon tea harvest yield, target progress, and fine leaf quality ratio.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
