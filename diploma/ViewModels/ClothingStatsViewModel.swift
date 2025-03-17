//
//  ClothingStatsViewModel.swift
//  diploma
//
//  Created by Olga on 03.03.2025.
//


import SwiftUI
import Combine

class ClothingStatsViewModel: ObservableObject {
    @Published var clothingStats: [ClothingStat] = []

    func fetchClothingStats() {
        clothingStats = [
            ClothingStat(id: UUID(), clothingItem: "Blue Jeans", usageCount: 12),
            ClothingStat(id: UUID(), clothingItem: "White T-Shirt", usageCount: 20),
            ClothingStat(id: UUID(), clothingItem: "Black Jacket", usageCount: 5),
            ClothingStat(id: UUID(), clothingItem: "Sneakers", usageCount: 15),
            ClothingStat(id: UUID(), clothingItem: "Cap", usageCount: 8)
        ]
    }

    var totalItems: Int {
        clothingStats.count
    }

    var weeklyUsage: Int {
        clothingStats.reduce(0) { $0 + $1.usageCount }
    }

    var mostPopularItem: String {
        clothingStats.max { $0.usageCount < $1.usageCount }?.clothingItem ?? "Нет данных"
    }

    /// **Топ 5 часто используемых вещей**
    func topFiveItems() -> [(String, String)] {
        let sortedItems = clothingStats.sorted { $0.usageCount > $1.usageCount }.prefix(5)
        return sortedItems.map { ($0.clothingItem, "\($0.usageCount) раз") }
    }

    /// **Статистика по сезонам (заглушка)**
    func seasonStats() -> [(String, String)] {
        return [
            ("Летние вещи", "12"),
            ("Зимние вещи", "8"),
            ("Осенние вещи", "10"),
            ("Весенние вещи", "7")
        ]
    }

    /// **Самые редко используемые вещи**
    func leastUsedItems() -> [(String, String)] {
        let sortedItems = clothingStats.sorted { $0.usageCount < $1.usageCount }.prefix(3)
        return sortedItems.map { ($0.clothingItem, "\($0.usageCount) раз") }
    }
}
