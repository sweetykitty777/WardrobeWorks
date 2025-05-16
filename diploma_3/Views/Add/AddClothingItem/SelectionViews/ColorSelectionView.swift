//
//  ColorSelectionView.swift
//  diploma
//
//  Created by Olga on 02.03.2025.
//

import Foundation
import SwiftUI

struct ColorSelectionView: View {
    @Binding var selectedColor: String

    let colors = ["Красный", "Синий", "Зелёный", "Чёрный", "Белый"]

    var body: some View {
        List {
            ForEach(colors, id: \ .self) { color in
                Button(action: {
                    selectedColor = color
                }) {
                    HStack {
                        Text(color)
                        Spacer()
                        if selectedColor == color {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                        }
                    }
                }
            }
        }
        .navigationTitle("Выберите цвет")
    }
}
