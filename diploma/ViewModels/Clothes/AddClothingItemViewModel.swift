import Foundation
import SwiftUI
import UIKit

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


    
    func fetchContentData() {
        WardrobeService.shared.fetchClothingTypes { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let types):
                    self.clothingTypes = types
                case .failure(let error):
                    print("Ошибка загрузки типов одежды: \(error)")
                }
            }
        }

        WardrobeService.shared.fetchSeasons { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let seasons):
                    self.seasons = seasons
                case .failure(let error):
                    print("Ошибка загрузки сезонов: \(error)")
                }
            }
        }
        
        WardrobeService.shared.fetchBrands { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let brands):
                    self.brands = brands
                case .failure(let error):
                    print("Ошибка загрузки сезонов: \(error)")
                }
            }
        }
        
        WardrobeService.shared.fetchColors { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let list):
                    self.colors = list
                case .failure(let error):
                    print("Ошибка загрузки цветов: \(error)")
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
                case .failure(let error):
                    print("Ошибка загрузки гардеробов: \(error)")
                }
            }
        }
    }

    func saveItem(wardrobeId: Int, completion: @escaping (Bool) -> Void) {
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
                DispatchQueue.main.async {
                    switch result {
                    case .success():
                        completion(true)
                    case .failure(let error):
                        print("Ошибка создания вещи: \(error)")
                        completion(false)
                    }
                }
            }
        }

        if let image = selectedImage {
            ImageUploadService.shared.uploadImage(image) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let imageUrl):
                        submitClothing(with: imageUrl)
                    case .failure(let error):
                        print("Ошибка загрузки изображения: \(error)")
                        completion(false)
                    }
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
