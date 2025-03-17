import Foundation

struct Outfit: Identifiable {
    let id: UUID
    var name: String
    var outfitItems: [OutfitItem] // ✅ Список вещей в аутфите
    var wardrobe: Wardrobe?
    var imageName: String? // ✅ Теперь у аутфита есть отдельное изображение

    init(id: UUID = UUID(), name: String, outfitItems: [OutfitItem], wardrobe: Wardrobe? = nil, imageName: String? = nil) {
        self.id = id
        self.name = name
        self.outfitItems = outfitItems
        self.wardrobe = wardrobe
        self.imageName = imageName // ✅ Добавляем изображение
    }
}
