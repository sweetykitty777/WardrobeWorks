import SwiftUI
import Combine
import PostHog

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

        PostHogSDK.shared.capture("clothing stats viewed", properties: [
            "items_count": clothingStats.count
        ])
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
        let result = sortedItems.map { ($0.clothingItem, "\($0.usageCount) раз") }

        PostHogSDK.shared.capture("clothing stats top items", properties: [
            "items": result.map { $0.0 }
        ])

        return result
    }

    func seasonStats() -> [(String, String)] {
        let data = [
            ("Летние вещи", "12"),
            ("Зимние вещи", "8"),
            ("Осенние вещи", "10"),
            ("Весенние вещи", "7")
        ]

        PostHogSDK.shared.capture("clothing stats season breakdown", properties: [
            "seasons": data.map { $0.0 }
        ])

        return data
    }

    func leastUsedItems() -> [(String, String)] {
        let sortedItems = clothingStats.sorted { $0.usageCount < $1.usageCount }.prefix(3)
        let result = sortedItems.map { ($0.clothingItem, "\($0.usageCount) раз") }

        PostHogSDK.shared.capture("clothing stats least used", properties: [
            "items": result.map { $0.0 }
        ])

        return result
    }
}
