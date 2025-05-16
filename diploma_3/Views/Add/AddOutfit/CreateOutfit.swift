//
//  CreateOutfit.swift
//  diploma
//
//  Created by Olga on 04.03.2025.
//

import Foundation
import SwiftUI

struct CreateOutfitView: View {
    @ObservedObject var viewModel: OutfitViewModel

    @State private var outfitName: String = ""
    @State private var selectedItems: [ClothingItem] = []

    var body: some View {
        NavigationStack {
            VStack {
                TextField("Название аутфита", text: $outfitName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                List(viewModel.clothingItems) { item in
                    HStack {
                        Text(item.name)
                        Spacer()
                        if selectedItems.contains(where: { $0.id == item.id }) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.blue)
                        }
                    }
                    .onTapGesture {
                        toggleSelection(for: item)
                    }
                }

                Button(action: saveOutfit) {
                    Text("Сохранить аутфит")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(outfitName.isEmpty || selectedItems.isEmpty ? Color.gray : Color.blue)
                        .cornerRadius(10)
                }
                .disabled(outfitName.isEmpty || selectedItems.isEmpty)
                .padding()
            }
            .navigationTitle("Создать аутфит")
        }
    }

    private func toggleSelection(for item: ClothingItem) {
        if let index = selectedItems.firstIndex(where: { $0.id == item.id }) {
            selectedItems.remove(at: index)
        } else {
            selectedItems.append(item)
        }
    }

    private func saveOutfit() {
        viewModel.addOutfit(name: outfitName, clothingItems: selectedItems)
    }
}
