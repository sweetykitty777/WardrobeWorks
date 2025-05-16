//
//  OutfitPickerView.swift
//  diploma
//
//  Created by Olga on 17.03.2025.
//

import Foundation
import SwiftUI

struct OutfitPickerView: View {
    @Binding var selectedOutfits: [Outfit]
    var onAdd: () -> Void
    @Environment(\.presentationMode) var presentationMode

    @State private var allOutfits: [Outfit] = MockData.outfits

    var body: some View {
        NavigationView {
            List(allOutfits, id: \.id) { outfit in
                HStack {
                    OutfitCard(outfit: outfit)
                    Spacer()
                    if selectedOutfits.contains(where: { $0.id == outfit.id }) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.blue)
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    if let index = selectedOutfits.firstIndex(where: { $0.id == outfit.id }) {
                        selectedOutfits.remove(at: index)
                    } else {
                        selectedOutfits.append(outfit) 
                    }
                }
            }
            .navigationTitle("Выбрать аутфиты")
            .navigationBarItems(
                leading: Button("Отмена") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Добавить") {
                    onAdd()
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
    }
}
