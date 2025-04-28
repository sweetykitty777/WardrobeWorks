import Foundation
import Combine

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
         print("fetchPosts(\(reset ? "reset" : "next")) → URL: \(urlString)")
         guard let url = URL(string: urlString) else {
             print("Invalid URL")
             isLoading = false
             return
         }

         var request = URLRequest(url: url)
         request.httpMethod = "GET"
         if let token = KeychainHelper.get(forKey: "accessToken") {
             print("Attaching token to headers")
             request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
         }

         URLSession.shared.dataTaskPublisher(for: request)
             .handleEvents(receiveSubscription: { _ in
                 print("fetchPosts: starting network request")
             }, receiveOutput: { output in
                 print("fetchPosts: received raw data (\(output.data.count) bytes)")
             }, receiveCompletion: { completion in
                 switch completion {
                 case .finished:
                     print("fetchPosts: network publisher finished")
                 case .failure(let error):
                     print("fetchPosts: network error:", error)
                 }
             })
             .map(\.data)
             .decode(type: [Post].self, decoder: JSONDecoder())
             .receive(on: DispatchQueue.main)
             .sink(
                 receiveCompletion: { [weak self] completion in
                     guard let self = self else { return }
                     self.isLoading = false
                     if case let .failure(error) = completion {
                         print("fetchPosts: decoding error:", error)
                     }
                 },
                 receiveValue: { [weak self] newPosts in
                     guard let self = self else { return }
                     print("fetchPosts: decoded \(newPosts.count) post(s) on page \(self.currentPage)")
                     for p in newPosts {
                         print("Post id=\(p.id), userId=\(p.user), likes=\(p.likes), text='\(p.text)'")
                     }

                     if newPosts.count < self.pageSize {
                         self.allLoaded = true
                         print("fetchPosts: allLoaded = true")
                     } else {
                         self.currentPage += 1
                         print("fetchPosts: next page = \(self.currentPage)")
                     }

                     self.posts.append(contentsOf: newPosts)
                     let newVMs = newPosts.map { PostViewModel(post: $0) }
                     self.postViewModels.append(contentsOf: newVMs)
                     self.isLoading = false
                 }
             )
             .store(in: &cancellables)
     }

    // MARK: — Подгрузка следующей страницы
    func loadMoreIfNeeded(currentPost post: Post) {
        guard !allLoaded, let last = posts.last, last.id == post.id else { return }
        fetchPosts()
    }

    // MARK: — Поиск пользователей по нику
    func searchUsers() {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        print("searchUsers() called with searchText = '\(searchText)' → query = '\(query)'")
        
        guard !query.isEmpty else {
            print("Query is empty, clearing results")
            searchResults = []
            return
        }

        let urlString = "https://gate-acidnaya.amvera.io/api/v1/social-service/users/find/username=\(query)"
        print("URL: \(urlString)")
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        if let token = KeychainHelper.get(forKey: "accessToken") {
            print("Found token, attaching Authorization header")
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else {
            print("No access token found")
        }

        URLSession.shared.dataTaskPublisher(for: request)
            .handleEvents(
                receiveSubscription: { _ in print("▶️ Starting network request") },
                receiveOutput: { output in
                    print("Сырые данные \(output.data.count) байты")
                },
                receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        print("Без ошибки")
                    case .failure(let err):
                        print("Network publisher failed with error:", err)
                    }
                },
                receiveCancel: {
                    print("Network publisher was cancelled")
                }
            )
            .map(\.data)
            .decode(type: [UserProfile].self, decoder: JSONDecoder())
            .sink(
                receiveCompletion: { completion in
                    if case let .failure(error) = completion {
                        print("Decoding failed:", error)
                    }
                },
                receiveValue: { [weak self] results in
                    guard let self = self else { return }
                    print("Decoded \(results.count) user(s):")
                    results.forEach { user in
                        print("id=\(user.id) username=@\(user.username) bio='\(user.bio ?? "")' avatar='\(user.avatar ?? "")'")
                    }
                    self.searchResults = results
                }
            )
            .store(in: &cancellables)
    }
    }
