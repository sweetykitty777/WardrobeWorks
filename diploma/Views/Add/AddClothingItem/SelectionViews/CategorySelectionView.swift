//
//  CategorySelectionView.swift
//  diploma
//
//  Created by Olga on 02.03.2025.
//

import Foundation
import SwiftUI

struct CategorySelectionView: View {
    @Binding var selectedCategory: String

    let categories = ["Верх", "Низ", "Верхняя одежда", "Платья", "Обувь", "Аксессуары"]

    var body: some View {
        List {
            ForEach(categories, id: \ .self) { category in
                Button(action: {
                    selectedCategory = category
                }) {
                    HStack {
                        Text(category)
                        Spacer()
                        if selectedCategory == category {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                        }
                    }
                }
            }
        }
        .navigationTitle("Выберите категорию")
    }
}
