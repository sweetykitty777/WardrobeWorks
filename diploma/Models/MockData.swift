

import Foundation
import SwiftUI

struct MockData {

    static let wardrobes: [Wardrobe] = [
        Wardrobe(name: "Мой гардероб"),
        Wardrobe(name: "Гардероб ребенка"),
    ]

    static let clothingItems: [ClothingItem] = [
        ClothingItem(name: "любимые джинсики", image_str: "jeans4", brand: "Levi’s", color: "Синий", season: "Лето", price: "$50"),
        ClothingItem(name: "", image_str: "top", category: "Верх", wardrobe: wardrobes[0]),
        ClothingItem(name: "", image_str: "bl", category: "Верх", wardrobe: wardrobes[0]),
        ClothingItem(name: "", image_str: "bl1", category: "Верх", wardrobe: wardrobes[0]),
        ClothingItem(name: "", image_str: "bl2", category: "Верх", wardrobe: wardrobes[0]),
        ClothingItem(name: "", image_str: "dr1", category: "Платья и комбинезоны", wardrobe: wardrobes[0]),
        ClothingItem(name: "", image_str: "coat", category: "Верхняя одежда", wardrobe: wardrobes[0]),
    ]
    
    static let outfitItems: [OutfitItem] = [
            OutfitItem(name: "любимые джинсики", imageName: "jeans4", position: CGPoint(x: 150, y: 150)),
            OutfitItem(name: "блузка", imageName: "bl1", position: CGPoint(x: 200, y: 200)),
            OutfitItem(name: "Куртка", imageName: "jacket", position: CGPoint(x: 250, y: 250)),
            OutfitItem(name: "Кроссовки", imageName: "sneakers", position: CGPoint(x: 300, y: 300)),
            OutfitItem(name: "Шапка", imageName: "hat", position: CGPoint(x: 350, y: 350))
    ]

    static let outfits: [Outfit] = [
            Outfit(name: "",
                   outfitItems: [outfitItems[0], outfitItems[1]],
                   imageName: "my_outfit2"),
            Outfit(name: "",
                   outfitItems: [outfitItems[2], outfitItems[4]],
                   imageName: "casual_outfit_2")
        ]

    static let collections: [Collection] = [
        Collection(name: "Мои лучшие образы", outfits: [outfits[0], outfits[1]])
    ]

    static let posts: [Post] = [
        Post(
            outfit: outfits[0],
            likes: 12,
            comments: ["Очень красиво!", "Где купить?"],
            description: "Отличный повседневный образ для прогулки в городе!",
            author: "annstylist"
        ),
        Post(
            outfit: outfits[1],
            likes: 8,
            comments: ["Обожаю осенние образы"],
            description: "Этот лук идеально подходит для прохладных дней.",
            author: "max77777"
        )
    ]
}
