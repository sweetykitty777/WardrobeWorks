//
//  CustomSelectableNavigationLink.swift
//  diploma
//
//  Created by Olga on 22.04.2025.
//

import Foundation
import SwiftUI

struct CustomSelectableNavigationLink<T: NamedItem, Destination: View>: View {
    let title: String
    @Binding var selectedItem: T?
    let destination: Destination
    var showColorDot: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.gray)

            NavigationLink(destination: destination) {
                HStack {
                    if showColorDot, let colorItem = selectedItem as? ClothingColor {
                        Circle()
                            .fill(Color(hex: colorItem.colourcode))
                            .frame(width: 16, height: 16)

                        Spacer().frame(width: 4) // ← безопасный способ задать отступ
                    }

                    Text(selectedItem?.name ?? "Добавить \(title.lowercased())")
                        .foregroundColor(.black)
                        .font(.system(size: 16, weight: .medium))

                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(.gray)
                }

                .padding()
                .frame(height: 44)
                .background(Color.white)
                .cornerRadius(14)
                .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
            }
        }
    }
}
