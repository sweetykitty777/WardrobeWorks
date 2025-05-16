//
//  OutfitCollectionsViewModel.swift
//  diploma
//
//  Created by Olga on 03.03.2025.
//

import Foundation
import SwiftUI
import Combine

class OutfitCollectionsViewModel: ObservableObject {
    @Published var collections: [OutfitCollection] = []

    init() {
        // Заглушка с тестовыми данными
        collections = [
            OutfitCollection(name: "Летние аутфиты", outfits: [
                Outfit(name: "Повседневный стиль", outfitItems: []),
                Outfit(name: "Вечерний выход", outfitItems: [])
            ]),
            OutfitCollection(name: "Зимняя одежда", outfits: [
                Outfit(name: "Уютный лук", outfitItems: []),
                Outfit(name: "Деловой стиль", outfitItems: [])
            ])
        ]
    }

    /// Добавить новую коллекцию
    func addCollection(name: String) {
        let newCollection = OutfitCollection(name: name, outfits: [])
        collections.append(newCollection)
    }

    /// Удалить коллекцию
    func removeCollection(_ collection: OutfitCollection) {
        collections.removeAll { $0.id == collection.id }
    }
}
