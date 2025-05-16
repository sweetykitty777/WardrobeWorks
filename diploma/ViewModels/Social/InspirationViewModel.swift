import Foundation
import Combine
import PostHog

class InspirationViewModel: ObservableObject {
    @Published var posts: [Post] = []
    @Published var postViewModels: [PostViewModel] = []
    @Published var searchText: String = ""
    @Published var searchResults: [UserProfile] = []

    private var cancellables = Set<AnyCancellable>()
    private var currentPage = 0
    private let pageSize = 10
    private var isLoading = false
    private var allLoaded = false

    func fetchPosts(reset: Bool = false) {
        guard !isLoading else { return }
        isLoading = true

        if reset {
            currentPage = 0
            allLoaded = false
            posts = []
            postViewModels = []
        }

        let urlString = "https://gate-acidnaya.amvera.io/api/v1/social-service/posts/feed?page=\(currentPage)&size=\(pageSize)"
        guard let url = URL(string: urlString) else {
            isLoading = false
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        if let token = KeychainHelper.get(forKey: "accessToken") {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        PostHogSDK.shared.capture("inspiration_feed_fetch_start", properties: ["page": currentPage])

        URLSession.shared.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: [Post].self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case let .failure(error) = completion {
                        PostHogSDK.shared.capture("inspiration_feed_fetch_failed", properties: [
                            "page": self?.currentPage ?? 0,
                            "error": error.localizedDescription
                        ])
                    }
                },
                receiveValue: { [weak self] newPosts in
                    guard let self = self else { return }

                    if newPosts.count < self.pageSize {
                        self.allLoaded = true
                        PostHogSDK.shared.capture("inspiration_feed_all_loaded", properties: ["page": self.currentPage])
                    } else {
                        self.currentPage += 1
                    }

                    self.posts.append(contentsOf: newPosts)
                    self.postViewModels.append(contentsOf: newPosts.map { PostViewModel(post: $0) })

                    PostHogSDK.shared.capture("inspiration_feed_fetch_success", properties: [
                        "page": self.currentPage - 1,
                        "posts_loaded": newPosts.count
                    ])
                }
            )
            .store(in: &cancellables)
    }

    func loadMoreIfNeeded(currentPost post: Post) {
        guard !allLoaded, let last = posts.last, last.id == post.id else { return }
        PostHogSDK.shared.capture("inspiration_feed_scroll_end", properties: ["last_post_id": post.id])
        fetchPosts()
    }

    func searchUsers() {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else {
            searchResults = []
            return
        }

        let urlString = "https://gate-acidnaya.amvera.io/api/v1/social-service/users/find/username=\(query)"
        guard let url = URL(string: urlString) else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        if let token = KeychainHelper.get(forKey: "accessToken") {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        PostHogSDK.shared.capture("inspiration_user_search", properties: ["query": query])

        URLSession.shared.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: [UserProfile].self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completion in
                    if case let .failure(error) = completion {
                        PostHogSDK.shared.capture("inspiration_user_search_failed", properties: [
                            "query": query,
                            "error": error.localizedDescription
                        ])
                    }
                },
                receiveValue: { [weak self] results in
                    self?.searchResults = results
                    PostHogSDK.shared.capture("inspiration_user_search_results", properties: [
                        "query": query,
                        "results_count": results.count
                    ])
                }
            )
            .store(in: &cancellables)
    }
}
