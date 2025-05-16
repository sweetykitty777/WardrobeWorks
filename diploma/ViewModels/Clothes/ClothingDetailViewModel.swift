import SwiftUI
import PostHog

@MainActor
class ClothingDetailViewModel: ObservableObject {
    let originalItem: ClothItem

    @Published var editableItem: ClothItem
    @Published var outfits: [OutfitResponse] = []
    @Published var isEditing = false
    @Published var isSaving = false
    @Published var showAlert = false
    @Published var alertMessage = ""

    @Published var price: String = ""
    @Published var description: String = ""

    @Published var selectedType: ClothingContentItem?
    @Published var selectedBrand: ClothingContentItem?
    @Published var selectedSeason: ClothingContentItem?
    @Published var selectedColor: ClothingColor?

    @Published var clothingTypes: [ClothingContentItem] = []
    @Published var brands: [ClothingContentItem] = []
    @Published var seasons: [ClothingContentItem] = []
    @Published var colors: [ClothingColor] = []

    init(item: ClothItem) {
        self.originalItem = item
        self.editableItem = item
        self.price = "\(item.price ?? 0)"
        self.description = item.description ?? ""
    }

    func loadContent() {
        PostHogSDK.shared.capture("clothing detail screen opened", properties: [
            "clothing_id": originalItem.id
        ])

        let service = WardrobeService.shared
        let group = DispatchGroup()
        var anyFailure = false

        group.enter()
        service.fetchClothingTypes { result in
            if case let .success(types) = result {
                DispatchQueue.main.async { self.clothingTypes = types }
            } else { anyFailure = true }
            group.leave()
        }

        group.enter()
        service.fetchBrands { result in
            if case let .success(brands) = result {
                DispatchQueue.main.async { self.brands = brands }
            } else { anyFailure = true }
            group.leave()
        }

        group.enter()
        service.fetchSeasons { result in
            if case let .success(seasons) = result {
                DispatchQueue.main.async { self.seasons = seasons }
            } else { anyFailure = true }
            group.leave()
        }

        group.enter()
        service.fetchColors { result in
            if case let .success(colors) = result {
                DispatchQueue.main.async { self.colors = colors }
            } else { anyFailure = true }
            group.leave()
        }

        group.notify(queue: .main) {
            self.selectedType = self.clothingTypes.first { $0.name == self.originalItem.typeName }
            self.selectedBrand = self.brands.first { $0.name == self.originalItem.brandName }
            self.selectedSeason = self.seasons.first { $0.name == self.originalItem.seasonName }
            self.selectedColor = self.colors.first { $0.name == self.originalItem.colourName }

            if anyFailure {
                PostHogSDK.shared.capture("clothing detail content failed", properties: [
                    "clothing_id": self.originalItem.id
                ])
            } else {
                PostHogSDK.shared.capture("clothing detail content loaded", properties: [
                    "clothing_id": self.originalItem.id
                ])
            }
        }
    }

    func fetchOutfits() {
        WardrobeService.shared.fetchOutfitsForClothing(id: originalItem.id) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let outfits):
                    self.outfits = outfits
                    PostHogSDK.shared.capture("clothing outfits loaded", properties: [
                        "clothing_id": self.originalItem.id,
                        "count": outfits.count
                    ])
                case .failure(let error):
                    print("Ошибка загрузки аутфитов:", error)
                    PostHogSDK.shared.capture("clothing outfits load failed", properties: [
                        "clothing_id": self.originalItem.id,
                        "error": error.localizedDescription
                    ])
                }
            }
        }
    }

    func saveChanges(onSuccess: @escaping () -> Void) {
        let request = UpdateClothingItemRequest(
            price: Int(price),
            typeId: selectedType?.id,
            colourId: selectedColor?.id,
            seasonId: selectedSeason?.id,
            brandId: selectedBrand?.id,
            description: description.isEmpty ? nil : description
        )

        guard request.price != nil ||
              request.typeId != nil ||
              request.colourId != nil ||
              request.seasonId != nil ||
              request.brandId != nil ||
              request.description != nil else {
            alertMessage = "Заполните хотя бы одно поле"
            showAlert = true
            return
        }

        isSaving = true
        WardrobeService.shared.updateClothingItem(id: editableItem.id, request: request) { result in
            DispatchQueue.main.async {
                self.isSaving = false
                switch result {
                case .success:
                    self.alertMessage = "Изменения сохранены"
                    self.editableItem = ClothItem(
                        id: self.editableItem.id,
                        description: request.description ?? self.editableItem.description,
                        imagePath: self.editableItem.imagePath,
                        price: request.price ?? self.editableItem.price,
                        typeName: self.selectedType?.name ?? self.editableItem.typeName,
                        colourName: self.selectedColor?.name ?? self.editableItem.colourName,
                        seasonName: self.selectedSeason?.name ?? self.editableItem.seasonName,
                        brandName: self.selectedBrand?.name ?? self.editableItem.brandName
                    )
                    self.isEditing = false
                    self.showAlert = true
                    PostHogSDK.shared.capture("clothing item updated", properties: [
                        "clothing_id": self.originalItem.id
                    ])
                    onSuccess()
                case .failure:
                    self.alertMessage = "Ошибка при сохранении"
                    self.showAlert = true
                    PostHogSDK.shared.capture("clothing item update failed", properties: [
                        "clothing_id": self.originalItem.id
                    ])
                }
            }
        }
    }

    func deleteClothingItem(completion: @escaping (Bool) -> Void) {
        WardrobeService.shared.deleteClothingItem(id: editableItem.id) { success in
            DispatchQueue.main.async {
                if success {
                    PostHogSDK.shared.capture("clothing item deleted", properties: [
                        "clothing_id": self.editableItem.id
                    ])
                }
                completion(success)
            }
        }
    }
}
