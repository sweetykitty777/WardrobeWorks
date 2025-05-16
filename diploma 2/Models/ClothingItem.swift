//
//  ClothingItem.swift
//  diploma
//
//  Created by Olga on 01.02.2025.
//

import Foundation
import SwiftUI

struct ClothingItem: Identifiable {
    var id = UUID()
    var name: String
    var image: UIImage?
    var image_str: String?
    var category: String?
    var brand: String?
    var color: String?
    var season: String?
    var price: String?
    var purchaseDate: Date?
    var note: String?
    var wardrobe: Wardrobe? // ✅ Теперь гардероб опциональный

    init(
        id: UUID = UUID(),
        name: String,
        image: UIImage? = nil,
        image_str: String? = nil,
        category: String? = nil,
        brand: String? = nil,
        color: String? = nil,
        season: String? = nil,
        price: String? = nil,
        purchaseDate: Date? = nil,
        note: String? = nil,
        wardrobe: Wardrobe? = nil // ✅ Теперь `wardrobe` может быть `nil`
    ) {
        self.id = id
        self.name = name
        self.image = image
        self.image_str = image_str
        self.category = category
        self.brand = brand
        self.color = color
        self.season = season
        self.price = price
        self.purchaseDate = purchaseDate
        self.note = note
        self.wardrobe = wardrobe
    }
}
