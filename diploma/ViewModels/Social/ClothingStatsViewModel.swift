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
            ClothingStat(id: UUID(), clothingItem: "Blue Jeans", usageCount: 0),
            ClothingStat(id: UUID(), clothingItem: "White T-Shirt", usageCount: 0),
            ClothingStat(id: UUID(), clothingItem: "Black Jacket", usageCount: 2),
            ClothingStat(id: UUID(), clothingItem: "Sneakers", usageCount: 1),
            ClothingStat(id: UUID(), clothingItem: "Cap", usageCount: 0)
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

    func topFiveItems() -> [(String, String)] {
        let sortedItems = clothingStats.sorted { $0.usageCount > $1.usageCount }.prefix(5)
        return sortedItems.map { ($0.clothingItem, "\($0.usageCount) раз") }
    }

    func seasonStats() -> [(String, String)] {
        return [
            ("Летние вещи", "12"),
            ("Зимние вещи", "8"),
            ("Осенние вещи", "10"),
            ("Весенние вещи", "7")
        ]
    }

    func leastUsedItems() -> [(String, String)] {
        let sortedItems = clothingStats.sorted { $0.usageCount < $1.usageCount }.prefix(3)
        return sortedItems.map { ($0.clothingItem, "\($0.usageCount) раз") }
    }
}
