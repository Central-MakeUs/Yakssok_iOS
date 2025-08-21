//
//  YakssokWidget.swift
//  Yakssok
//
//  Created by 김사랑 on 8/20/25.
//

import WidgetKit
import SwiftUI

private enum Shared {
    static let appGroupId = "group.yakssok.shared"
    static let keyTodayList = "widget_today_medications"
}

struct MedicationEntry: TimelineEntry {
    let date: Date
    let displayTime: String
    let displayName: String?
    let hasToday: Bool
}

private struct WidgetMedicineData: Codable {
    let id: String
    let name: String
    let dosage: String?
    let time: String
}

struct Provider: TimelineProvider {

    func placeholder(in context: Context) -> MedicationEntry {
        MedicationEntry(date: Date(), displayTime: "pm 1:00", displayName: "유산균", hasToday: true)
    }

    func getSnapshot(in context: Context, completion: @escaping (MedicationEntry) -> Void) {
        completion(makeEntry(for: Date()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<MedicationEntry>) -> Void) {
        let now = Date()
        let entry = makeEntry(for: now)

        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: now) ?? now
        let timeline = Timeline(entries: [entry], policy: .atEnd)
        completion(timeline)
    }

    private func makeEntry(for now: Date) -> MedicationEntry {
        guard let sharedDefaults = UserDefaults(suiteName: Shared.appGroupId),
              let data = sharedDefaults.data(forKey: Shared.keyTodayList),
              let medicines = try? JSONDecoder().decode([WidgetMedicineData].self, from: data) else {
            return MedicationEntry(date: now, displayTime: "오늘은 없어요!", displayName: nil, hasToday: false)
        }

        guard let nextMedicine = findNextMedicine(from: medicines, currentTime: now) else {
            return MedicationEntry(date: now, displayTime: "오늘은 없어요!", displayName: nil, hasToday: false)
        }

        let timeText = formatTimePM(nextMedicine.time)
        return MedicationEntry(date: now, displayTime: timeText, displayName: nextMedicine.name, hasToday: true)
    }

    private func findNextMedicine(from medicines: [WidgetMedicineData], currentTime: Date) -> (time: Date, name: String)? {
        let calendar = Calendar.current
        let todayComponents = calendar.dateComponents([.year, .month, .day], from: currentTime)

        let candidates: [(Date, String)] = medicines.compactMap { medicine in
            guard let timeComponents = parseTimeString(medicine.time) else { return nil }

            var components = DateComponents()
            components.year = todayComponents.year
            components.month = todayComponents.month
            components.day = todayComponents.day
            components.hour = timeComponents.hour
            components.minute = timeComponents.minute
            components.second = 0

            guard let medicineTime = calendar.date(from: components) else { return nil }
            return (medicineTime, medicine.name)
        }

        return candidates
            .filter { $0.0 >= currentTime && calendar.isDate($0.0, inSameDayAs: currentTime) }
            .sorted(by: { $0.0 < $1.0 })
            .first
    }

    private func parseTimeString(_ timeString: String) -> (hour: Int, minute: Int)? {
        let components = timeString.split(separator: ":")
        guard components.count == 2,
              let hour = Int(components[0]),
              let minute = Int(components[1]),
              (0..<24).contains(hour),
              (0..<60).contains(minute) else {
            return nil
        }
        return (hour, minute)
    }

    private func formatTimePM(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "a h:mm"
        return formatter.string(from: date).lowercased()
    }
}

struct AccessoryContentView: View {
    @Environment(\.widgetFamily) private var family
    let entry: MedicationEntry

    var body: some View {
        content
            .containerBackground(.clear, for: .widget)
    }

    @ViewBuilder
    private var content: some View {
        switch family {
        case .accessoryInline:
            inlineView

        case .accessoryCircular:
            circularView

        case .accessoryRectangular:
            rectangularView

        default:
            EmptyView()
        }
    }

    private var inlineView: some View {
        Text(entry.hasToday ? "복약 \(entry.displayTime)" : "오늘은 없어요!")
    }

    private var circularView: some View {
        ZStack {
            Circle()
                .fill(.primary.opacity(0.3))

            if entry.hasToday {
                VStack(spacing: 1) {
                    let parts = entry.displayTime.split(separator: " ")
                    if parts.count >= 2 {
                        Text(String(parts[0]))
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.primary)
                            .padding(.top, 5)

                        Text(String(parts[1]))
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.primary)
                    } else {
                        Text(entry.displayTime)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.primary)
                    }

                    Image("pillIcon")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 23, height: 10)
                        .foregroundColor(.primary)
                        .padding(.bottom, 5)
                }
            } else {
                VStack(spacing: 1) {
                    Image("pillIcon")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 40, height: 26)
                        .foregroundColor(.primary)
                }
            }
        }
    }

    private var rectangularView: some View {
        HStack(spacing: 6) {
            VStack(alignment: .leading, spacing: 4) {
                Image("pillIcon")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 20, height: 9)
                    .foregroundColor(.primary)
                    .padding(.bottom, 5)

                Text("지금 먹을 약")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)

                if entry.hasToday, let name = entry.displayName {
                    Text("\(entry.displayTime) \(name)")
                        .font(.system(size: 14, weight: .medium))
                        .lineLimit(1)
                        .foregroundColor(.secondary)
                        .padding(.bottom, 5)
                } else {
                    Text("오늘은 없어요!")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                        .padding(.bottom, 5)
                }
            }

            Spacer()
        }
        .padding(.top, 10)
        .padding(.horizontal, 2)
    }
}

struct YakssokWidget: Widget {
    let kind: String = "YakssokWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            AccessoryContentView(entry: entry)
        }
        .configurationDisplayName("약쏙")
        .description("다음에 섭취할 복약을 확인합니다.")
        .supportedFamilies([.accessoryInline, .accessoryCircular, .accessoryRectangular])
    }
}

@main
struct YakssokWidgetBundle: WidgetBundle {
    var body: some Widget {
        YakssokWidget()
    }
}
