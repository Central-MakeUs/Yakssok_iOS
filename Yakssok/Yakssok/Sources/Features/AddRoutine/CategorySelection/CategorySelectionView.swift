//
//  CategorySelectionView.swift
//  Yakssok
//
//  Created by 김사랑 on 7/14/25.
//

import SwiftUI
import ComposableArchitecture
import YakssokDesignSystem

struct CategorySelectionView: View {
    let store: StoreOf<CategorySelectionFeature>
    @State private var localMedicineName: String = ""

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack(alignment: .leading, spacing: 0) {
                medicineNameSection(viewStore: viewStore)

                Spacer()
                    .frame(height: 32)

                categorySelectionSection(viewStore: viewStore)

                Spacer()
            }
            .onAppear {
                localMedicineName = viewStore.medicineName
            }
        }
    }

    private func medicineNameSection(viewStore: ViewStoreOf<CategorySelectionFeature>) -> some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("\(viewStore.userNickname)님이 먹을 약은 무엇인가요?")
                .font(YKFont.subtitle2)
                .foregroundColor(YKColor.Neutral.grey950)

            MedicineNameTextField(
                text: $localMedicineName,
                placeholder: AddRoutineConstants.Placeholder.medicineName,
                characterCount: viewStore.medicineNameCharacterCount,
                onTextChanged: { name in
                    viewStore.send(.medicineNameChanged(name))
                }
            )
        }
        .padding(.horizontal, 16)
    }

    private func categorySelectionSection(viewStore: ViewStoreOf<CategorySelectionFeature>) -> some View {
        VStack(alignment: .leading, spacing: 20) {
            Text(AddRoutineConstants.StepTitle.categoryQuestion)
                .font(YKFont.subtitle2)
                .foregroundColor(YKColor.Neutral.grey950)
                .padding(.horizontal, 16)

            CategorySelectionGrid(
                categories: viewStore.categories,
                selectedCategory: viewStore.selectedCategory,
                onCategorySelected: { category in
                    viewStore.send(.categorySelected(category))
                }
            )
            .padding(.horizontal, 16)
        }
    }
}
