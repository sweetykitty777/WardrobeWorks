import Foundation
import SwiftUI
import PostHog

class ClothingDetailPublicViewModel: ObservableObject {
    @Published var wardrobes: [UsersWardrobe] = []

    func fetchWardrobes() {
        WardrobeService.shared.fetchWardrobes { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let wardrobes):
                    self.wardrobes = wardrobes
                    PostHogSDK.shared.capture("public clothing wardrobes loaded", properties: [
                        "count": wardrobes.count
                    ])
                case .failure(let error):
                    print("Ошибка загрузки гардеробов:", error)
                    PostHogSDK.shared.capture("public clothing wardrobes failed", properties: [
                        "error": error.localizedDescription
                    ])
                }
            }
        }
    }

    func copyItem(clothId: Int, to wardrobeId: Int, completion: @escaping () -> Void) {
        WardrobeService.shared.copyItem(clothId: clothId, to: wardrobeId) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    PostHogSDK.shared.capture("clothing item copied", properties: [
                        "cloth_id": clothId,
                        "to_wardrobe_id": wardrobeId
                    ])
                    completion()
                case .failure(let error):
                    print("Ошибка копирования вещи: \(error.localizedDescription)")
                    PostHogSDK.shared.capture("clothing item copy failed", properties: [
                        "cloth_id": clothId,
                        "to_wardrobe_id": wardrobeId,
                        "error": error.localizedDescription
                    ])
                }
            }
        }
    }
}
