import Foundation

struct Outfit: Identifiable {
    let id: UUID
    var name: String
    var outfitItems: [OutfitItem] // ✅ Теперь используем `outfitItems`
    var wardrobe: Wardrobe?

    init(id: UUID = UUID(), name: String, outfitItems: [OutfitItem], wardrobe: Wardrobe? = nil) {
        self.id = id
        self.name = name
        self.outfitItems = outfitItems
        self.wardrobe = wardrobe
    }
}
