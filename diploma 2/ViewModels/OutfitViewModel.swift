//
//  OutfitViewModel.swift
//  diploma
//
//  Created by Olga on 03.03.2025.
//

import Foundation
import SwiftUI
import Combine

class OutfitViewModel: ObservableObject {
    @Published var outfits: [Outfit] = []

    init() {
        loadMockData() // ✅ Загружаем тестовые данные при создании ViewModel
    }

    /// ✅ Добавляет новый аутфит с `outfitItems`
    func addOutfit(name: String, outfitItems: [OutfitItem], wardrobe: Wardrobe? = nil) {
        let newOutfit = Outfit(name: name, outfitItems: outfitItems, wardrobe: wardrobe)
        outfits.append(newOutfit)
        print("✅ Аутфит сохранён: \(newOutfit.name) с \(newOutfit.outfitItems.count) вещами")
    }

    /// ✅ Удаляет аутфит по `id`
    func removeOutfit(_ outfit: Outfit) {
        outfits.removeAll { $0.id == outfit.id }
        print("🗑 Аутфит удален: \(outfit.name)")
    }
    
    /// ✅ Загружаем тестовые аутфиты
    private func loadMockData() {
        outfits = [
            Outfit(name: "Повседневный стиль", outfitItems: [
                OutfitItem(name: "Джинсы", imageName: "jeans", position: CGPoint(x: 150, y: 150)),
                OutfitItem(name: "Футболка", imageName: "tshirt", position: CGPoint(x: 200, y: 200)),
                OutfitItem(name: "Кроссовки", imageName: "sneakers", position: CGPoint(x: 250, y: 250))
            ]),
            Outfit(name: "Деловой стиль", outfitItems: [
                OutfitItem(name: "Костюм", imageName: "suit", position: CGPoint(x: 150, y: 150)),
                OutfitItem(name: "Рубашка", imageName: "shirt", position: CGPoint(x: 200, y: 200)),
                OutfitItem(name: "Туфли", imageName: "shoes", position: CGPoint(x: 250, y: 250))
            ])
        ]
    }
}
