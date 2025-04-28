//
//  OtherUserProfileViewModel.swift
//  diploma
//

import Foundation
import Combine

class OtherUserProfileViewModel: ObservableObject {
    @Published var user: UserProfile = UserProfile(id: 0, username: "", bio: nil, avatar: nil)
    @Published var posts: [Post] = []
    @Published var publicItems: [ClothItem] = []
    @Published var publicOutfits: [OutfitResponse] = []
    @Published var publicLookbooks: [LookbookResponse] = []

    @Published var isFollowing: Bool = false
    @Published var loadingFollowState: Bool = false

    private var cancellables = Set<AnyCancellable>()

    func loadProfile(for userId: Int) {
        fetchUser(userId: userId)
        fetchUserPosts(userId: userId)
        fetchWardrobesAndContent(for: userId)
        checkFollowing(followedId: userId)
    }

    private func fetchUser(userId: Int) {
        UserProfileService.shared.fetchUserById(userId) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let user):
                    self.user = user
                case .failure(let error):
                    print("Ошибка загрузки пользователя:", error)
                }
            }
        }
    }

    private func fetchUserPosts(userId: Int) {
        PostService.shared.fetchUserPosts(userId: userId) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let posts):
                    self.posts = posts
                case .failure(let error):
                    print("Ошибка загрузки постов:", error)
                }
            }
        }
    }

    private func fetchWardrobesAndContent(for userId: Int) {
        WardrobeService.shared.getWardrobes(of: userId) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let wardrobes):
                    for wardrobe in wardrobes {
                        WardrobeService.shared.fetchClothes(for: wardrobe.id) { clothesResult in
                            if case let .success(clothes) = clothesResult {
                                DispatchQueue.main.async {
                                    self.publicItems.append(contentsOf: clothes)
                                }
                            }
                        }

                        OutfitService.shared.fetchOutfits(for: wardrobe.id) { outfitsResult in
                            if case let .success(outfits) = outfitsResult {
                                DispatchQueue.main.async {
                                    self.publicOutfits.append(contentsOf: outfits)
                                }
                            }
                        }

                        LookbookService.shared.fetchLookbooks(for: wardrobe.id) { lookbookResult in
                            if case let .success(lookbooks) = lookbookResult {
                                DispatchQueue.main.async {
                                    self.publicLookbooks.append(contentsOf: lookbooks)
                                }
                            }
                        }
                    }
                case .failure(let error):
                    print("Ошибка загрузки гардеробов:", error)
                }
            }
        }
    }

    func checkFollowing(followedId: Int) {
        guard let token = KeychainHelper.get(forKey: "accessToken"),
              let url = URL(string: "https://gate-acidnaya.amvera.io/api/v1/social-service/follow/is-following/\(followedId)")
        else {
            print("Неверный URL для проверки подписки")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.addValue("*/*", forHTTPHeaderField: "Accept")

        URLSession.shared.dataTaskPublisher(for: request)
            .handleEvents(receiveOutput: { output in
                if let raw = String(data: output.data, encoding: .utf8) {
                    print("is-following raw response:", raw)
                }
            })
            .tryMap { output -> Data in
                let code = (output.response as? HTTPURLResponse)?.statusCode ?? -1
                guard (200...299).contains(code) else {
                    throw URLError(.badServerResponse)
                }
                return output.data
            }
            .decode(type: Bool.self, decoder: JSONDecoder())
            .replaceError(with: false)
            .receive(on: DispatchQueue.main)
            .sink { _ in } receiveValue: { isFollowing in
                print("Результат is-following(\(followedId)):", isFollowing)
                self.isFollowing = isFollowing
            }
            .store(in: &cancellables)
    }

    func follow(followedId: Int) {
        changeFollowState(followedId: followedId, method: "POST") { success in
            if success {
                self.isFollowing = true
                print("Теперь вы подписаны на пользователя \(followedId)")
            } else {
                print("Не удалось подписаться на пользователя \(followedId)")
            }
        }
    }

    func unfollow(followedId: Int) {
        changeFollowState(followedId: followedId, method: "DELETE") { success in
            if success {
                self.isFollowing = false
                print("Вы отписались от пользователя \(followedId)")
            } else {
                print("Не удалось отписаться от пользователя \(followedId)")
            }
        }
    }

    private func changeFollowState(followedId: Int, method: String, completion: @escaping (Bool) -> Void) {
        guard let token = KeychainHelper.get(forKey: "accessToken"),
              let url = URL(string: "https://gate-acidnaya.amvera.io/api/v1/social-service/follow/\(followedId)")
        else {
            print("Неверный URL для follow/unfollow")
            return
        }

        loadingFollowState = true

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.addValue("*/*", forHTTPHeaderField: "Accept")

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                self.loadingFollowState = false

                if let http = response as? HTTPURLResponse {
                    print("Ответ follow \(method):", http.statusCode)
                }

                if let data = data, let body = String(data: data, encoding: .utf8) {
                    print("follow \(method) response body:", body)
                }

                if let http = response as? HTTPURLResponse {
                    completion((200...299).contains(http.statusCode))
                } else {
                    print("Нет HTTP-ответа при \(method) follow")
                    completion(false)
                }

                if let err = error {
                    print("Ошибка network follow \(method):", err)
                }
            }
        }.resume()
    }
}
