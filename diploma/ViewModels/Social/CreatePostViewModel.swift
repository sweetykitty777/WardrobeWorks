import Foundation
import Combine

@MainActor
class CreatePostViewModel: ObservableObject {
    @Published var wardrobes: [UsersWardrobe] = []
    @Published var selectedWardrobeId: Int?
    @Published var selectedOutfit: OutfitResponse?
    @Published var description: String = ""
    @Published var isLoading: Bool = false
    @Published var toastMessage: String = ""
    @Published var showToast: Bool = false

    func fetchWardrobes() {
        WardrobeService.shared.fetchWardrobes { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let fetched):
                    self?.wardrobes = fetched.filter { !$0.isPrivate }
                    print("Загруженные гардеробы: \(fetched.map { $0.name })")
                case .failure(let error):
                    print("Ошибка загрузки гардеробов: \(error.localizedDescription)")
                    self?.showToast(message: "Ошибка гардеробов: \(error.localizedDescription)")
                }
            }
        }
    }

    func createPost() {
        guard let outfit = selectedOutfit else {
            showToast(message: "Нет выбранного аутфита")
            return
        }

        isLoading = true
        SocialService.shared.createPost(outfit: outfit, text: description) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success:
                    self?.description = ""
                    self?.selectedOutfit = nil
                    self?.showToast(message: "Пост опубликован!")
                case .failure(let error):
                    self?.showToast(message: "Ошибка создания поста: \(error.localizedDescription)")
                }
            }
        }
    }

    func showToast(message: String) {
        toastMessage = message
        showToast = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.showToast = false
        }
    }
}
