import Foundation
import SwiftUI
import Combine
import PostHog

class OutfitViewModel: ObservableObject {
    @Published var outfits: [OutfitResponse] = []
    @Published var isLoading = false

    func addOutfit(name: String, description: String, wardrobeId: Int, placedItems: [PlacedClothingItem]) {
        let clothesData = placedItems.map {
            OutfitClothPlacement(
                clothId: $0.clothId,
                x: $0.x,
                y: $0.y,
                rotation: $0.rotation,
                scale: $0.scale,
                zindex: $0.zIndex
            )
        }

        let payload = FullOutfitEditRequest(
            name: name,
            description: description,
            imagePath: "",
            clothes: clothesData
        )

        WardrobeService.shared.createOutfit(wardrobeId: wardrobeId, payload: payload) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    PostHogSDK.shared.capture("outfit created", properties: [
                        "wardrobe_id": wardrobeId,
                        "items_count": clothesData.count
                    ])
                case .failure(let error):
                    PostHogSDK.shared.capture("outfit create failed", properties: [
                        "wardrobe_id": wardrobeId,
                        "error": error.localizedDescription
                    ])
                }
            }
        }
    }
    
    func fetchOutfits(for wardrobeId: Int) {
        isLoading = true

        WardrobeService.shared.fetchOutfits(for: wardrobeId) { result in
            DispatchQueue.main.async {
                self.isLoading = false

                switch result {
                case .success(let outfits):
                    self.outfits = outfits
                    PostHogSDK.shared.capture("outfits loaded", properties: [
                        "wardrobe_id": wardrobeId,
                        "count": outfits.count
                    ])
                case .failure(let error):
                    self.outfits = []
                    PostHogSDK.shared.capture("outfits load failed", properties: [
                        "wardrobe_id": wardrobeId,
                        "error": error.localizedDescription
                    ])
                }
            }
        }
    }


    func fetchOutfit(id: Int, completion: @escaping (Result<OutfitResponse, Error>) -> Void) {
        WardrobeService.shared.fetchOutfit(id: id) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let outfit):
                    completion(.success(outfit))
                    PostHogSDK.shared.capture("outfit loaded", properties: ["outfit_id": id])
                case .failure(let error):
                    completion(.failure(error))
                    PostHogSDK.shared.capture("outfit load failed", properties: [
                        "outfit_id": id,
                        "error": error.localizedDescription
                    ])
                }
            }
        }
    }

    func removeOutfit(_ outfit: OutfitResponse) {
        outfits.removeAll { $0.id == outfit.id }
        print("Аутфит удален: \(outfit.name)")
        PostHogSDK.shared.capture("outfit removed", properties: [
            "outfit_id": outfit.id,
            "name": outfit.name
        ])
    }
}
