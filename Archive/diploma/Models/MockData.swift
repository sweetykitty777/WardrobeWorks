//
//  MockData.swift
//  diploma
//
//  Created by Olga on 04.03.2025.
//

import Foundation
import SwiftUI

struct MockData {

    static let wardrobes: [Wardrobe] = [
        Wardrobe(name: "Мой гардероб"),
        Wardrobe(name: "Гардероб ребенка"),
    ]

    static let clothingItems: [ClothingItem] = [
        ClothingItem(name: "", image_str: "jeans4", category: "Низ", wardrobe: wardrobes[0]),
        ClothingItem(name: "", image_str: "top", category: "Верх", wardrobe: wardrobes[0]),
        ClothingItem(name: "", image_str: "bl", category: "Верх", wardrobe: wardrobes[0]),
        ClothingItem(name: "", image_str: "bl1", category: "Верх", wardrobe: wardrobes[0]),
        ClothingItem(name: "", image_str: "bl2", category: "Верх", wardrobe: wardrobes[0]),
        ClothingItem(name: "", image_str: "dr1", category: "Платья и комбинезоны", wardrobe: wardrobes[0]),
        ClothingItem(name: "", image_str: "coat", category: "Верхняя одежда", wardrobe: wardrobes[0]),
    ]
    
    static let outfits: [Outfit] = [
        Outfit(name: "Повседневный", outfitItems: [
            OutfitItem(name: "Джинсы", imageName: "jeans", position: CGPoint(x: 150, y: 150)),
            OutfitItem(name: "Футболка", imageName: "tshirt", position: CGPoint(x: 200, y: 200))
        ]),
        Outfit(name: "Деловой стиль", outfitItems: [
            OutfitItem(name: "Костюм", imageName: "suit", position: CGPoint(x: 250, y: 250)),
            OutfitItem(name: "Рубашка", imageName: "shirt", position: CGPoint(x: 300, y: 300))
        ])
    ]

    static let lookbooks: [Lookbook] = [
        Lookbook(name: "Осенний стиль", outfits: [outfits[0], outfits[1]])
    ]

    static let posts: [Post] = [
        Post(author: "Анна", date: Date(), likes: 15, comments: ["Отличный образ!"], outfit: outfits[0]),
        Post(author: "Максим", date: Date(), likes: 8, comments: ["Стильно!"], lookbook: lookbooks[0])
    ]
}
