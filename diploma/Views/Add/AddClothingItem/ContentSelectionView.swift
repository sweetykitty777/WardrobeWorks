//
//  ContentSelectionView.swift
//  diploma
//
//  Created by Olga on 22.04.2025.
//

import Foundation
import SwiftUI

struct ContentSelectionView<T: NamedItem>: View {
    let items: [T]
    @Binding var selectedItem: T?

    var body: some View {
        List {
            ForEach(items) { item in
                HStack {
                    if let colorItem = item as? ClothingColor {
                        Circle()
                            .fill(Color(hex: colorItem.colourcode))
                            .frame(width: 20, height: 20)
                    }

                    Text(item.name)
                    Spacer()

                    if selectedItem?.id == item.id {
                        Image(systemName: "checkmark")
                            .foregroundColor(.blue)
                    }
                }
                .contentShape(Rectangle()) // Расширяет область нажатия
                .onTapGesture {
                    selectedItem = item
                }
            }
        }
        .navigationTitle("Выбор")
        .navigationBarTitleDisplayMode(.inline)
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r = Double((int >> 16) & 0xFF) / 255
        let g = Double((int >> 8) & 0xFF) / 255
        let b = Double(int & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }
}
