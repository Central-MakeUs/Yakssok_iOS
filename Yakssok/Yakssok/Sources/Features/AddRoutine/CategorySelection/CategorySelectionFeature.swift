//
//  CategorySelectionFeature.swift
//  Yakssok
//
//  Created by 김사랑 on 7/14/25.
//

import ComposableArchitecture

struct CategorySelectionFeature: Reducer {
    struct State: Equatable {
        var medicineName: String = ""
        var selectedCategory: MedicineCategory?
        let categories: [MedicineCategory] = MedicineCategory.defaultCategories

        var isNextButtonEnabled: Bool {
            !medicineName.trimmingCharacters(in: .whitespaces).isEmpty && selectedCategory != nil
        }

        var medicineNameCharacterCount: String {
            "\(medicineName.count)/\(AddRoutineConstants.maxMedicineNameLength)"
        }
    }

    @CasePathable
    enum Action: Equatable {
        case medicineNameChanged(String)
        case categorySelected(MedicineCategory)
        case nextButtonTapped
    }

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .medicineNameChanged(let name):
                if name.count <= AddRoutineConstants.maxMedicineNameLength {
                    state.medicineName = name
                }
                return .none
            case .categorySelected(let category):
                state.selectedCategory = category
                return .none
            case .nextButtonTapped:
                return .none
            }
        }
    }
}
