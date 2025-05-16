import Foundation
import SwiftUI
import PostHog

class ClothesViewModel: ObservableObject {
    @Published var clothes: [ClothItem] = []
    @Published var errorMessage: String?
    @Published var isLoading: Bool = false
    
    @StateObject private var clothesViewModel = ClothesViewModel()
    


    func fetchClothes(for wardrobeId: Int) {
        isLoading = true

        WardrobeService.shared.fetchClothes(for: wardrobeId) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false

                switch result {
                case .success(let items):
                    self?.clothes = items

                    PostHogSDK.shared.capture("clothes loaded", properties: [
                        "wardrobe_id": wardrobeId,
                        "count": items.count
                    ])

                case .failure(let error):
                    self?.errorMessage = "Ошибка загрузки одежды: \(error.localizedDescription)"

                    PostHogSDK.shared.capture("clothes load failed", properties: [
                        "wardrobe_id": wardrobeId,
                        "error": error.localizedDescription
                    ])
                }
            }
        }
    }
}
