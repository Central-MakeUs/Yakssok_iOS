//
//  CategorySelectionGrid.swift
//  Yakssok
//
//  Created by 김사랑 on 7/14/25.
//

import SwiftUI
import YakssokDesignSystem

struct CategorySelectionGrid: View {
    let categories: [MedicineCategory]
    let selectedCategory: MedicineCategory?
    let onCategorySelected: (MedicineCategory) -> Void

    var body: some View {
        VStack(spacing: AddRoutineConstants.Layout.categoryButtonSpacing) {
            categoryRow(indices: 0..<2)
            categoryRow(indices: 2..<4)
            categoryRow(indices: 4..<5)
            categoryRow(indices: 5..<7)
        }
    }

    private func categoryRow(indices: Range<Int>) -> some View {
        HStack(spacing: AddRoutineConstants.Layout.categoryButtonSpacing) {
            ForEach(indices, id: \.self) { index in
                if index < categories.count {
                    CategoryButton(
                        category: categories[index],
                        isSelected: selectedCategory?.id == categories[index].id,
                        onTap: { onCategorySelected(categories[index]) }
                    )
                }
            }
            Spacer()
        }
    }
}
