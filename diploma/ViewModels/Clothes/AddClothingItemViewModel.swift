import Foundation
import SwiftUI
import UIKit
import PostHog

class AddClothingItemViewModel: ObservableObject {
    @Published var itemName: String = ""
    @Published var selectedImage: UIImage?
    @Published var showingImagePicker = false
    @Published var category: String = ""
    @Published var brand: String = ""
    @Published var color: String = ""
    @Published var season: String = ""
    @Published var price: String = ""
    @Published var purchaseDate: Date = Date()
    @Published var note: String = ""
    @Published var wardrobes: [UsersWardrobe] = []
    @Published var selectedWardrobeName: String = "Выбрать"
    @Published var selectedWardrobeId: Int?
    @Published var clothingTypes: [ClothingContentItem] = []
    @Published var seasons: [ClothingContentItem] = []
    @Published var brands: [ClothingContentItem] = []
    @Published var colors: [ClothingColor] = []
    
    @Published var selectedColor: ClothingColor?
    @Published var selectedType: ClothingContentItem?
    @Published var selectedSeason: ClothingContentItem?
    @Published var selectedBrand: ClothingContentItem?
    @Published var isSaving: Bool = false


    func fetchContentData() {
        WardrobeService.shared.fetchClothingTypes { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let types):
                    self.clothingTypes = types
                    PostHogSDK.shared.capture("clothing content loaded", properties: ["type": "types"])
                case .failure(let error):
                    print("Ошибка загрузки типов одежды: \(error)")
                    PostHogSDK.shared.capture("clothing content load failed", properties: [
                        "type": "types",
                        "error": error.localizedDescription
                    ])
                }
            }
        }

        WardrobeService.shared.fetchSeasons { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let seasons):
                    self.seasons = seasons
                    PostHogSDK.shared.capture("clothing content loaded", properties: ["type": "seasons"])
                case .failure(let error):
                    print("Ошибка загрузки сезонов: \(error)")
                    PostHogSDK.shared.capture("clothing content load failed", properties: [
                        "type": "seasons",
                        "error": error.localizedDescription
                    ])
                }
            }
        }
        
        WardrobeService.shared.fetchBrands { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let brands):
                    self.brands = brands
                    PostHogSDK.shared.capture("clothing content loaded", properties: ["type": "brands"])
                case .failure(let error):
                    print("Ошибка загрузки брендов: \(error)")
                    PostHogSDK.shared.capture("clothing content load failed", properties: [
                        "type": "brands",
                        "error": error.localizedDescription
                    ])
                }
            }
        }
        
        WardrobeService.shared.fetchColors { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let list):
                    self.colors = list
                    PostHogSDK.shared.capture("clothing content loaded", properties: ["type": "colors"])
                case .failure(let error):
                    print("Ошибка загрузки цветов: \(error)")
                    PostHogSDK.shared.capture("clothing content load failed", properties: [
                        "type": "colors",
                        "error": error.localizedDescription
                    ])
                }
            }
        }
    }

    func fetchWardrobes() {
        WardrobeService.shared.fetchWardrobes { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let list):
                    self.wardrobes = list
                    if self.selectedWardrobeId == nil {
                        self.selectedWardrobeId = list.first?.id
                        self.selectedWardrobeName = list.first?.name ?? "Выбрать"
                    }
                    PostHogSDK.shared.capture("wardrobes loaded", properties: [
                        "count": list.count
                    ])
                case .failure(let error):
                    print("Ошибка загрузки гардеробов: \(error)")
                    PostHogSDK.shared.capture("wardrobes load failed", properties: [
                        "error": error.localizedDescription
                    ])
                }
            }
        }
    }

    func saveItem(wardrobeId: Int, completion: @escaping (Bool) -> Void) {
        guard !isSaving else { return } // предотвратить дублирование
        isSaving = true

        func complete(_ success: Bool) {
            DispatchQueue.main.async {
                self.isSaving = false
                completion(success)
            }
        }

        func submitClothing(with imageUrl: String) {
            let request = CreateClothingItemRequest(
                price: Int(price) ?? 0,
                typeId: selectedType?.id ?? 0,
                colourId: selectedColor?.id ?? 0,
                seasonId: selectedSeason?.id ?? 0,
                brandId: selectedBrand?.id ?? 0,
                description: note,
                imagePath: imageUrl
            )

            WardrobeService.shared.createClothingItem(wardrobeId: wardrobeId, request: request) { result in
                switch result {
                case .success:
                    PostHogSDK.shared.capture("clothing item created", properties: [
                        "wardrobe_id": wardrobeId,
                        "type_id": request.typeId,
                        "color_id": request.colourId,
                        "season_id": request.seasonId,
                        "brand_id": request.brandId,
                        "has_image": !imageUrl.isEmpty
                    ])
                    complete(true)
                case .failure(let error):
                    print("Ошибка создания вещи: \(error)")
                    PostHogSDK.shared.capture("clothing item create failed", properties: [
                        "wardrobe_id": wardrobeId,
                        "error": error.localizedDescription
                    ])
                    complete(false)
                }
            }
        }

        if let image = selectedImage {
            WardrobeService.shared.uploadPNGImage(image) { result in
                switch result {
                case .success(let imageUrl):
                    if let image = self.selectedImage {
                        ImageCache.shared.setImage(image, forKey: imageUrl)
                    }
                    submitClothing(with: imageUrl)
                case .failure(let error):
                    print("Ошибка загрузки изображения: \(error)")
                    PostHogSDK.shared.capture("clothing item create failed", properties: [
                        "wardrobe_id": wardrobeId,
                        "error": error.localizedDescription,
                        "stage": "image upload"
                    ])
                    complete(false)
                }
            }
        } else {
            submitClothing(with: "")
        }

    }


    func resetForm() {
        itemName = ""
        selectedImage = nil
        category = ""
        brand = ""
        color = ""
        season = ""
        price = ""
        purchaseDate = Date()
        note = ""
    }
}
