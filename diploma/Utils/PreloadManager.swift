import Foundation
import PostHog
import UIKit

class PreloadManager {
    static let shared = PreloadManager()

    func preloadResources() {
        PostHogSDK.shared.capture("preload started")

        fetchWardrobes { wardrobes in
            guard !wardrobes.isEmpty else {
                PostHogSDK.shared.capture("preload skipped")
                return
            }

            PostHogSDK.shared.capture("preload wardrobes loaded")

            let group = DispatchGroup()

            for wardrobe in wardrobes {
                group.enter()
                self.preloadClothes(wardrobeId: wardrobe.id) {
                    group.leave()
                }

                group.enter()
                self.preloadOutfits(wardrobeId: wardrobe.id) {
                    group.leave()
                }
            }

            group.notify(queue: .main) {
                PostHogSDK.shared.capture("preload finished")
            }
        }
    }

    private func fetchWardrobes(completion: @escaping ([UsersWardrobe]) -> Void) {
        WardrobeService.shared.fetchWardrobes { result in
            switch result {
            case .success(let wardrobes):
                completion(wardrobes)
            case .failure(let error):
                PostHogSDK.shared.capture("preload wardrobes failed", properties: [
                    "error": error.localizedDescription
                ])
                completion([])
            }
        }
    }

    private func preloadClothes(wardrobeId: Int, completion: @escaping () -> Void) {
        WardrobeService.shared.fetchClothes(for: wardrobeId) { result in
            switch result {
            case .success(let items):
                for item in items {
                    self.preloadImage(urlString: item.imagePath)
                }
                PostHogSDK.shared.capture("preload clothes completed", properties: [
                    "wardrobe_id": wardrobeId,
                    "items_count": items.count
                ])
            case .failure(let error):
                PostHogSDK.shared.capture("preload clothes failed", properties: [
                    "wardrobe_id": wardrobeId,
                    "error": error.localizedDescription
                ])
            }
            completion()
        }
    }

    private func preloadOutfits(wardrobeId: Int, completion: @escaping () -> Void) {
        WardrobeService.shared.fetchOutfits(for: wardrobeId) { result in
            switch result {
            case .success(let outfits):
                OutfitCache.shared.set(outfits, for: wardrobeId)
                for outfit in outfits {
                    if let imagePath = outfit.imagePath {
                        self.preloadImage(urlString: imagePath)
                    }
                }

                PostHogSDK.shared.capture("preload outfits completed", properties: [
                    "wardrobe_id": wardrobeId,
                    "outfit_count": outfits.count
                ])
            case .failure(let error):
                PostHogSDK.shared.capture("preload outfits failed", properties: [
                    "wardrobe_id": wardrobeId,
                    "error": error.localizedDescription
                ])
            }
            completion()
        }
    }


    private func preloadImage(urlString: String) {
        guard ImageCache.shared.image(forKey: urlString) == nil,
              let url = URL(string: urlString) else { return }

        URLSession.shared.dataTask(with: url) { data, _, _ in
            if let data = data, let image = UIImage(data: data) {
                ImageCache.shared.setImage(image, forKey: urlString)
            }
        }.resume()
    }
}
