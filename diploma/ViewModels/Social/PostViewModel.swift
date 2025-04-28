import Foundation
import Combine

class PostViewModel: ObservableObject {
    // MARK: — Исходный пост и состояние лайка
    @Published var post: Post
    @Published var likeCount: Int
    @Published var isLiked: Bool = false

    @Published var username: String = ""

    private var cancellables = Set<AnyCancellable>()

    init(post: Post) {
        self.post = post
        self.likeCount = post.likes
        self.isLiked = post.isLiked
        fetchUsername(for: post.user)
    }

    func didTapLike() {
        if isLiked {
            unlike()
        } else {
            like()
        }
    }

    
    private func like() {
        guard let url = URL(string: "https://gate-acidnaya.amvera.io/api/v1/social-service/posts/\(post.id)/like") else {
            print("Invalid URL for like")
            return
        }
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        if let token = KeychainHelper.get(forKey: "accessToken") {
            req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        req.addValue("*/*", forHTTPHeaderField: "Accept")

        print("POST \(url.absoluteString)")
        URLSession.shared.dataTask(with: req) { [weak self] _, response, error in
            DispatchQueue.main.async {
                guard let self = self else { return }
                if let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) {
                    self.isLiked = true
                    self.likeCount += 1
                    self.post.likes = self.likeCount
                    print("Liked post \(self.post.id)")
                } else {
                    print("Failed to like post \(self.post.id):", error ?? "status \((response as? HTTPURLResponse)?.statusCode ?? -1)")
                }
            }
        }.resume()
    }

    
    private func unlike() {
        guard let url = URL(string: "https://gate-acidnaya.amvera.io/api/v1/social-service/posts/\(post.id)/unlike") else {
            print("Invalid URL for unlike")
            return
        }
        var req = URLRequest(url: url)
        req.httpMethod = "DELETE"
        if let token = KeychainHelper.get(forKey: "accessToken") {
            req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        req.addValue("*/*", forHTTPHeaderField: "Accept")

        print("🌐 DELETE \(url.absoluteString)")
        URLSession.shared.dataTask(with: req) { [weak self] _, response, error in
            DispatchQueue.main.async {
                guard let self = self else { return }
                if let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) {
                    self.isLiked = false
                    self.likeCount = max(0, self.likeCount - 1)
                    self.post.likes = self.likeCount
                } else {
                    print("Failed to unlike post \(self.post.id):", error ?? "status \((response as? HTTPURLResponse)?.statusCode ?? -1)")
                }
            }
        }.resume()
    }

    private func fetchUsername(for userId: Int) {
        guard let url = URL(string: "https://gate-acidnaya.amvera.io/api/v1/social-service/users/\(userId)") else { return }
        var req = URLRequest(url: url)
        req.httpMethod = "GET"
        if let token = KeychainHelper.get(forKey: "accessToken") {
            req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        URLSession.shared.dataTaskPublisher(for: req)
            .map(\.data)
            .decode(type: UserProfile.self, decoder: JSONDecoder())
            .replaceError(with: UserProfile(id: userId, username: "unknown", bio: nil, avatar: nil))
            .receive(on: DispatchQueue.main)
            .sink { [weak self] user in
                self?.username = user.username
            }
            .store(in: &cancellables)
    }
}
