// ViewModel
import Foundation
import Combine

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
            print("createPost: outfit не выбран")
            return
        }

        let payload: [String: Any] = [
            "text": description,
            "postImages": [
                [
                    "imagePath": outfit.imagePath ?? "",
                    "position": 0,
                    "outfitId": outfit.id
                ]
            ]
        ]

        guard let url = URL(string: "https://gate-acidnaya.amvera.io/api/v1/social-service/posts/create") else {
            showToast(message: "Невалидный URL")
            print("createPost: невалидный URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        if let token = KeychainHelper.get(forKey: "accessToken") {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            print("Authorization: Bearer \(token)")
        } else {
            print("Токен не найден")
        }

        do {
            let jsonData = try JSONSerialization.data(withJSONObject: payload)
            request.httpBody = jsonData

            if let jsonString = String(data: jsonData, encoding: .utf8) {
                print("Отправляемый JSON:\n\(jsonString)")
            }
        } catch {
            showToast(message: "Ошибка сериализации: \(error.localizedDescription)")
            print("Ошибка сериализации: \(error.localizedDescription)")
            return
        }

        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.showToast(message: "Ошибка: \(error.localizedDescription)")
                    print("Сетевая ошибка: \(error.localizedDescription)")
                    return
                }

                if let httpResponse = response as? HTTPURLResponse {
                    print("Код ответа: \(httpResponse.statusCode)")
                }

                if let data = data, let raw = String(data: data, encoding: .utf8) {
                    print("Ответ сервера:\n\(raw)")
                }

                if let httpResponse = response as? HTTPURLResponse,
                   (200..<300).contains(httpResponse.statusCode) {
                    self?.description = ""
                    self?.selectedOutfit = nil
                    self?.showToast(message: "Пост опубликован!")
                } else {
                    self?.showToast(message: "Ошибка сервера")
                    print("Ошибка при создании поста")
                }
            }
        }.resume()
    }

    func showToast(message: String) {
        toastMessage = message
        showToast = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.showToast = false
        }
    }
}
