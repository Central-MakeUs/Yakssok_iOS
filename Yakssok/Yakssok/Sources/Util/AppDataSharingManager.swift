//
//  AppDataSharingManager.swift
//  Yakssok
//
//  Created by 김사랑 on 8/20/25.
//

import Foundation
import WidgetKit

struct WidgetMedicine: Codable {
    let id: String
    let name: String
    let dosage: String?
    let time: String

    init(from medicine: Medicine) {
        self.id = medicine.id
        self.name = medicine.name
        self.dosage = medicine.dosage
        self.time = Self.convertTo24HourFormat(medicine.time)
    }

    private static func convertTo24HourFormat(_ timeString: String) -> String {
        let inputFormatter = DateFormatter()
        inputFormatter.locale = Locale(identifier: "ko_KR")
        inputFormatter.dateFormat = "a h:mm"

        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "HH:mm"

        if let date = inputFormatter.date(from: timeString) {
            return outputFormatter.string(from: date)
        }

        return timeString
    }
}

final class AppDataSharingManager {
    static let shared = AppDataSharingManager()

    private let sharedDefaults: UserDefaults?
    private let groupIdentifier = "group.yakssok.shared"
    private let widgetKind = "YakssokWidget"
    private let medicineDataKey = "widget_today_medications"

    private init() {
        self.sharedDefaults = UserDefaults(suiteName: groupIdentifier)
    }

    /// 위젯용 약 데이터 업데이트
    func updateWidgetMedicineData(_ medicines: [Medicine]) {
        guard let sharedDefaults = sharedDefaults else { return }

        let widgetMedicines = medicines.map { WidgetMedicine(from: $0) }

        do {
            let data = try JSONEncoder().encode(widgetMedicines)
            sharedDefaults.set(data, forKey: medicineDataKey)
            sharedDefaults.synchronize()

            reloadWidget()
        } catch {
            // error
        }
    }

    /// 약 복용 완료 시 위젯 데이터 업데이트
    func updateMedicineCompletion(medicineId: String) {
        removeMedicineFromWidget(medicineId: medicineId)
    }

    /// 복약 종료 시 위젯 데이터에서 제거
    func terminateMedicine(medicineId: String) {
        removeMedicineFromWidget(medicineId: medicineId)
    }

    /// 약 데이터 초기화 (로그아웃, 회원탈퇴)
    func clearWidgetData() {
        guard let sharedDefaults = sharedDefaults else { return }

        sharedDefaults.removeObject(forKey: medicineDataKey)
        sharedDefaults.synchronize()

        reloadWidget()
    }

    private func removeMedicineFromWidget(medicineId: String) {
        guard let sharedDefaults = sharedDefaults,
              let data = sharedDefaults.data(forKey: medicineDataKey),
              var medicines = try? JSONDecoder().decode([WidgetMedicine].self, from: data) else {
            return
        }

        medicines.removeAll { $0.id == medicineId }

        do {
            let updatedData = try JSONEncoder().encode(medicines)
            sharedDefaults.set(updatedData, forKey: medicineDataKey)
            sharedDefaults.synchronize()

            reloadWidget()
        } catch {
            // error
        }
    }

    private func reloadWidget() {
        WidgetCenter.shared.reloadTimelines(ofKind: widgetKind)

        // 새로고침
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            WidgetCenter.shared.reloadTimelines(ofKind: self.widgetKind)
        }
    }
}
