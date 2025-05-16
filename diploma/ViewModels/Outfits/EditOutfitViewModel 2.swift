//
//  EditOutfitViewModel 2.swift
//  diploma
//
//  Created by Olga on 07.05.2025.
//


import SwiftUI
import Combine

class EditOutfitViewModel: ObservableObject {
    @Published var name: String = ""
    @Published var description: String = ""
    @Published var placedItems: [PlacedClothingItem] = []
    @Published var imageURLsByClothId: [Int: String] = [:]
    @Published var isSaving: Bool = false

    func loadOutfit(id: Int) {
        WardrobeService.shared.fetchFullOutfit(id: id) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let outfit):
                    self.name = outfit.name
                    self.description = outfit.description
                    self.placedItems = outfit.clothes.map { item in
                        self.imageURLsByClothId[item.clothId] = item.imagePath
                        return PlacedClothingItem(
                            clothId: item.clothId,
                            x: item.x,
                            y: item.y,
                            rotation: item.rotation,
                            scale: item.scale,
                            zIndex: item.zindex
                        )
                    }

                case .failure(let error):
                    print("Ошибка загрузки аутфита: \(error)")
                }
            }
        }
    }

    func saveChanges(outfitId: Int, completion: @escaping () -> Void) {
        isSaving = true

        let placements = placedItems.map {
            OutfitClothPlacement(
                clothId: $0.clothId,
                x: $0.x,
                y: $0.y,
                rotation: $0.rotation,
                scale: $0.scale,
                zindex: $0.zIndex
            )
        }

        let payload = FullOutfitEditRequest(
            name: name,
            description: description,
            imagePath: "",
            clothes: placements
        )

        WardrobeService.shared.updateOutfit(id: outfitId, payload: payload) { result in
            DispatchQueue.main.async {
                self.isSaving = false
                switch result {
                case .success:
                    print("Аутфит обновлён")
                    completion()
                case .failure(let error):
                    print("Ошибка при сохранении: \(error)")
                }
            }
        }
    }

    func removeItem(_ item: PlacedClothingItem) {
        placedItems.removeAll { $0.clothId == item.clothId }
        imageURLsByClothId.removeValue(forKey: item.clothId)
    }
}