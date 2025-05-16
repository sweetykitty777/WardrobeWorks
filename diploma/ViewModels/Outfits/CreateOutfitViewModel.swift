import SwiftUI
import PostHog

class CreateOutfitViewModel: ObservableObject {
    @Published var wardrobes: [UsersWardrobe] = []
    @Published var selectedWardrobeId: Int?
    @Published var selectedWardrobeName: String = "Выбрать гардероб"

    @Published var placedItems: [PlacedClothingItem] = []
    @Published var imageURLsByClothId: [Int: String] = [:]

    @Published var showingWardrobe: Bool = false
    @Published var showToast: Bool = false
    @Published var toastMessage: String = ""
    @Published var isSaving: Bool = false

    private var renderedImages: [Int: UIImage] = [:]

    func selectWardrobe(_ wardrobe: UsersWardrobe) {
        selectedWardrobeId = wardrobe.id
        selectedWardrobeName = wardrobe.name
    }

    func selectWardrobeById(_ id: Int) {
        if let existing = wardrobes.first(where: { $0.id == id }) {
            selectWardrobe(existing)
        } else {
            fetchWardrobes {
                if let fetched = self.wardrobes.first(where: { $0.id == id }) {
                    self.selectWardrobe(fetched)
                }
            }
        }
    }

    func fetchWardrobes(onComplete: (() -> Void)? = nil) {
        WardrobeService.shared.fetchWardrobes { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let list):
                    self.wardrobes = list
                    PostHogSDK.shared.capture("create outfit wardrobe loaded", properties: [
                        "count": list.count
                    ])
                case .failure(let error):
                    self.toastMessage = "Ошибка загрузки гардеробов: \(error.localizedDescription)"
                    self.showToast = true
                    PostHogSDK.shared.capture("create outfit wardrobe failed", properties: [
                        "error": error.localizedDescription
                    ])
                }
                onComplete?()
            }
        }
    }

    func fetchOutfit(id: Int, completion: @escaping (Result<OutfitResponse, Error>) -> Void) {
        WardrobeService.shared.fetchOutfit(id: id) { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }
    }

    func removeItem(_ item: PlacedClothingItem) {
        placedItems.removeAll { $0.clothId == item.clothId }
        PostHogSDK.shared.capture("create outfit item removed", properties: [
            "cloth_id": item.clothId
        ])
    }

    func saveOutfit(onComplete: @escaping () -> Void) {
        guard let wardrobeId = selectedWardrobeId else {
            toastMessage = "Выберите гардероб"
            showToast = true
            return
        }

        isSaving = true
        PostHogSDK.shared.capture("create outfit started", properties: [
            "wardrobe_id": wardrobeId,
            "items_count": placedItems.count
        ])

        preloadImages { success in
            guard success else {
                self.toastMessage = "Ошибка загрузки изображений"
                self.showToast = true
                self.isSaving = false
                PostHogSDK.shared.capture("create outfit image failed", properties: [
                    "reason": "image preload failed"
                ])
                return
            }

            let canvasSize = self.canvasSizeForRendering()

            OutfitImageBuilder.renderImage(
                from: self.placedItems,
                images: self.renderedImages,
                canvasSize: canvasSize
            ) { image in
                guard let originalImage = image else {
                    self.toastMessage = "Не удалось создать изображение"
                    self.showToast = true
                    self.isSaving = false
                    PostHogSDK.shared.capture("create outfit image failed", properties: [
                        "reason": "image render failed"
                    ])
                    return
                }

                let resizedImage = self.resizeImageIfNeeded(originalImage)

                PostHogSDK.shared.capture("create outfit image upload", properties: [
                    "original_size": "\(Int(originalImage.size.width))x\(Int(originalImage.size.height))",
                    "resized_size": "\(Int(resizedImage.size.width))x\(Int(resizedImage.size.height))"
                ])

                WardrobeService.shared.uploadPNGImage(resizedImage) { result in
                    DispatchQueue.main.async {
                        switch result {
                        case .success(let imagePath):
                            self.sendOutfitToServer(imagePath: imagePath, wardrobeId: wardrobeId, onComplete: onComplete)
                        case .failure(let error):
                            self.toastMessage = "Ошибка загрузки изображения: \(error.localizedDescription)"
                            self.showToast = true
                            self.isSaving = false
                            PostHogSDK.shared.capture("create outfit image failed", properties: [
                                "reason": "upload failed",
                                "error": error.localizedDescription
                            ])
                        }
                    }
                }
            }
        }
    }

    private func resizeImageIfNeeded(_ image: UIImage, maxSize: CGFloat = 1024) -> UIImage {
        let maxDimension = max(image.size.width, image.size.height)
        guard maxDimension > maxSize else {
            return image
        }

        let scale = maxSize / maxDimension
        let newSize = CGSize(
            width: image.size.width * scale,
            height: image.size.height * scale
        )

        let renderer = UIGraphicsImageRenderer(size: newSize)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }

    private func preloadImages(completion: @escaping (Bool) -> Void) {
        let group = DispatchGroup()
        var success = true

        for item in placedItems {
            guard let urlString = imageURLsByClothId[item.clothId],
                  let url = URL(string: urlString) else { continue }

            group.enter()
            URLSession.shared.dataTask(with: url) { data, _, _ in
                defer { group.leave() }
                if let data = data, let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self.renderedImages[item.clothId] = image
                    }
                } else {
                    success = false
                }
            }.resume()
        }

        group.notify(queue: .main) {
            completion(success)
        }
    }

    private func sendOutfitToServer(imagePath: String, wardrobeId: Int, onComplete: @escaping () -> Void) {
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

        let request = CreateOutfitRequest(
            name: "Новый аутфит",
            description: "",
            wardrobeId: wardrobeId,
            imagePath: imagePath,
            clothes: placements
        )

        WardrobeService.shared.createOutfit(payload: request) { result in
            DispatchQueue.main.async {
                self.isSaving = false
                switch result {
                case .success:
                    self.toastMessage = "Аутфит успешно создан"
                    self.showToast = true
                    PostHogSDK.shared.capture("create outfit success", properties: [
                        "wardrobe_id": wardrobeId,
                        "items_count": placements.count
                    ])
                    onComplete()
                case .failure(let error):
                    self.toastMessage = "Ошибка создания аутфита: \(error.localizedDescription)"
                    self.showToast = true
                    PostHogSDK.shared.capture("create outfit failed", properties: [
                        "wardrobe_id": wardrobeId,
                        "error": error.localizedDescription
                    ])
                }
            }
        }
    }

    private func canvasSizeForRendering() -> CGSize {
        guard !placedItems.isEmpty else {
            return CGSize(width: 300, height: 400)
        }

        let padding: CGFloat = 40
        var minX = CGFloat.greatestFiniteMagnitude
        var minY = CGFloat.greatestFiniteMagnitude
        var maxX: CGFloat = 0
        var maxY: CGFloat = 0

        for item in placedItems {
            guard let image = renderedImages[item.clothId] else { continue }

            let size = CGSize(
                width: image.size.width * item.scale,
                height: image.size.height * item.scale
            )
            let x = item.x - size.width / 2
            let y = item.y - size.height / 2

            minX = min(minX, x)
            minY = min(minY, y)
            maxX = max(maxX, x + size.width)
            maxY = max(maxY, y + size.height)
        }

        guard minX != .greatestFiniteMagnitude else {
            return CGSize(width: 300, height: 400)
        }

        let rawWidth = maxX - minX + padding * 2
        let rawHeight = maxY - minY + padding * 2

        let maxCanvasWidth: CGFloat = 800
        let maxCanvasHeight: CGFloat = 1000

        let width = min(max(rawWidth, 300), maxCanvasWidth)
        let height = min(max(rawHeight, 400), maxCanvasHeight)

        return CGSize(width: width, height: height)
    }
}
