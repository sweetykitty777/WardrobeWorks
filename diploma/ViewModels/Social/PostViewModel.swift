import Foundation
import Combine
import PostHog

class PostViewModel: ObservableObject {
    @Published var post: Post
    @Published var likeCount: Int
    @Published var isLiked: Bool = false
    @Published var username: String = ""

    private var cancellables = Set<AnyCancellable>()

    init(post: Post) {
        self.post = post
        self.likeCount = post.likes
        self.isLiked = post.isLiked
        PostHogSDK.shared.capture("post_viewed", properties: ["post_id": post.id])
        loadUsername()
    }

    func didTapLike() {
        let service = SocialService.shared
        let action = isLiked ? service.unlikePost : service.likePost

        action(post.id) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    guard let self = self else { return }
                    self.isLiked.toggle()
                    self.likeCount += self.isLiked ? 1 : -1
                    self.post.likes = self.likeCount
                    PostHogSDK.shared.capture(
                        self.isLiked ? "post_liked" : "post_unliked",
                        properties: ["post_id": self.post.id]
                    )
                case .failure(let error):
                    PostHogSDK.shared.capture("post_like_failed", properties: ["post_id": self?.post.id ?? 0, "error": error.localizedDescription])
                }
            }
        }
    }

    private func loadUsername() {
        SocialService.shared.fetchUsername(for: post.user) { [weak self] result in
            DispatchQueue.main.async {
                self?.username = (try? result.get()) ?? "unknown"
                PostHogSDK.shared.capture("post_username_loaded", properties: [
                    "post_id": self?.post.id ?? 0,
                    "username": self?.username ?? "unknown"
                ])
            }
        }
    }
}
