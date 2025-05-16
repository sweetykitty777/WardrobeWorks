import Foundation
import Combine
import PostHog

class CommentsViewModel: ObservableObject {
    let postId: Int

    @Published var comments: [Comment] = []
    @Published var newCommentText: String = ""
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var currentUserId: Int?

    private var cancellables = Set<AnyCancellable>()

    init(postId: Int) {
        self.postId = postId
    }

    func start() {
        isLoading = true
        PostHogSDK.shared.capture("comments_screen_opened", properties: ["post_id": postId])
        fetchCurrentUserAndComments()
    }

    private func fetchCurrentUserAndComments() {
        SocialService.shared.fetchCurrentUser { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let user):
                    self?.currentUserId = user.id
                    self?.fetchComments()
                case .failure(let error):
                    self?.isLoading = false
                    self?.errorMessage = "Ошибка загрузки профиля: \(error.localizedDescription)"
                    PostHogSDK.shared.capture("comments_user_fetch_failed", properties: ["post_id": self?.postId ?? 0, "error": error.localizedDescription])
                }
            }
        }
    }

    func fetchComments() {
        SocialService.shared.fetchComments(for: postId) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let comments):
                    self?.comments = comments
                    PostHogSDK.shared.capture("comments_loaded", properties: ["post_id": self?.postId ?? 0, "count": comments.count])
                case .failure(let error):
                    self?.errorMessage = "Не удалось загрузить комментарии: \(error.localizedDescription)"
                    PostHogSDK.shared.capture("comments_load_failed", properties: ["post_id": self?.postId ?? 0, "error": error.localizedDescription])
                }
            }
        }
    }

    func addComment() {
        let trimmed = newCommentText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        newCommentText = ""

        SocialService.shared.addComment(to: postId, text: trimmed) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.fetchComments()
                    PostHogSDK.shared.capture("comment_added", properties: ["post_id": self?.postId ?? 0])
                case .failure(let error):
                    self?.errorMessage = "Ошибка отправки: \(error.localizedDescription)"
                    PostHogSDK.shared.capture("comment_add_failed", properties: ["post_id": self?.postId ?? 0, "error": error.localizedDescription])
                }
            }
        }
    }

    func deleteComment(_ commentId: Int) {
        SocialService.shared.deleteComment(id: commentId) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.comments.removeAll { $0.id == commentId }
                    PostHogSDK.shared.capture("comment_deleted", properties: ["post_id": self?.postId ?? 0, "comment_id": commentId])
                case .failure(let error):
                    self?.errorMessage = "Ошибка удаления: \(error.localizedDescription)"
                    PostHogSDK.shared.capture("comment_delete_failed", properties: ["post_id": self?.postId ?? 0, "comment_id": commentId, "error": error.localizedDescription])
                }
            }
        }
    }
}
