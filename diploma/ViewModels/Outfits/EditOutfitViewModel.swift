import SwiftUI
import Combine
import PostHog

class EditOutfitViewModel: ObservableObject {
    @Published var name: String = ""
    @Published var description: String = ""
    @Published var placedItems: [PlacedClothingItem] = []
    @Published var imageURLsByClothId: [Int: String] = [:]
    @Published var isSaving: Bool = false

    var canvasSize: CGSize = CGSize(width: 400, height: 600)

    func loadOutfit(id: Int) {
        WardrobeService.shared.fetchFullOutfit(id: id) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let outfit):
                    self.name = outfit.name
                    self.description = outfit.description
                    self.placedItems = outfit.clothes.map { item in
                        self.imageURLsByClothId[item.cloth_id] = item.imagePath
                        return PlacedClothingItem(
                            clothId: item.cloth_id,
                            x: item.x,
                            y: item.y,
                            rotation: item.rotation,
                            scale: item.scale,
                            zIndex: item.zindex
                        )
                    }

                    PostHogSDK.shared.capture("outfit edit loaded", properties: [
                        "outfit_id": id,
                        "items_count": self.placedItems.count
                    ])

                case .failure(let error):
                    print("Ошибка загрузки аутфита: \(error)")
                    PostHogSDK.shared.capture("outfit edit load failed", properties: [
                        "outfit_id": id,
                        "error": error.localizedDescription
                    ])
                }
            }
        }
    }
    
    private func loadImagesAsync(from urls: [Int: String], completion: @escaping ([Int: UIImage]) -> Void) {
        var results: [Int: UIImage] = [:]
        let group = DispatchGroup()

        for (clothId, urlString) in urls {
            guard let url = URL(string: urlString) else { continue }

            group.enter()
            URLSession.shared.dataTask(with: url) { data, _, _ in
                defer { group.leave() }

                if let data = data, let image = UIImage(data: data) {
                    results[clothId] = image
                    ImageCache.shared.setImage(image, forKey: urlString) // кэш
                }
            }.resume()
        }

        group.notify(queue: .main) {
            completion(results)
        }
    }


    func saveChanges(outfitId: Int, completion: @escaping () -> Void) {
        isSaving = true

        loadImagesAsync(from: imageURLsByClothId) { renderedImages in
            OutfitImageBuilder.renderImage(
                from: self.placedItems,
                images: renderedImages,
                canvasSize: self.canvasSize
            ) { image in
                guard let image = image else {
                    self.isSaving = false
                    PostHogSDK.shared.capture("edit outfit image failed", properties: [
                        "outfit_id": outfitId,
                        "reason": "image render failed"
                    ])
                    return
                }

                PostHogSDK.shared.capture("edit outfit image upload", properties: [
                    "outfit_id": outfitId
                ])

                WardrobeService.shared.uploadPNGImage(image) { result in
                    DispatchQueue.main.async {
                        switch result {
                        case .success(let imagePath):
                            self.sendOutfitToServer(
                                imagePath: imagePath,
                                outfitId: outfitId,
                                completion: completion
                            )
                        case .failure(let error):
                            self.isSaving = false
                            PostHogSDK.shared.capture("edit outfit image upload failed", properties: [
                                "outfit_id": outfitId,
                                "error": error.localizedDescription
                            ])
                        }
                    }
                }
            }
        }
    }



    private func sendUpdateRequest(with imagePath: String, outfitId: Int, completion: @escaping () -> Void) {
        let placements = placedItems.map {
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
            imagePath: imagePath,
            clothes: placements
        )

        WardrobeService.shared.updateOutfit(id: outfitId, payload: payload) { result in
            DispatchQueue.main.async {
                self.isSaving = false
                switch result {
                case .success:
                    PostHogSDK.shared.capture("outfit updated", properties: [
                        "outfit_id": outfitId,
                        "items_count": self.placedItems.count
                    ])
                    completion()
                case .failure(let error):
                    PostHogSDK.shared.capture("outfit update failed", properties: [
                        "outfit_id": outfitId,
                        "error": error.localizedDescription
                    ])
                }
            }
        }
    }
    
    private func sendOutfitToServer(imagePath: String, outfitId: Int, completion: @escaping () -> Void) {
        let placements = placedItems.map {
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
            imagePath: imagePath,
            clothes: placements
        )

        WardrobeService.shared.updateOutfit(id: outfitId, payload: payload) { result in
            DispatchQueue.main.async {
                self.isSaving = false
                switch result {
                case .success:
                    PostHogSDK.shared.capture("outfit updated", properties: [
                        "outfit_id": outfitId,
                        "items_count": self.placedItems.count
                    ])
                    completion()
                case .failure(let error):
                    PostHogSDK.shared.capture("outfit update failed", properties: [
                        "outfit_id": outfitId,
                        "error": error.localizedDescription
                    ])
                }
            }
        }
    }

    

    func removeItem(_ item: PlacedClothingItem) {
        placedItems.removeAll { $0.clothId == item.clothId }
        imageURLsByClothId.removeValue(forKey: item.clothId)

        PostHogSDK.shared.capture("outfit item removed", properties: [
            "cloth_id": item.clothId
        ])
    }
}
