import Foundation
import Combine
import PostHog

class UserCalendarSearchViewModel: ObservableObject {
    @Published var searchText: String = ""
    @Published var searchResults: [UserProfile] = []

    private var cancellables = Set<AnyCancellable>()

    func searchUsers() {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else {
            searchResults = []
            return
        }

        PostHogSDK.shared.capture("calendar_user_search_started", properties: [
            "query": query
        ])

        let urlString = "https://gate-acidnaya.amvera.io/api/v1/social-service/users/find/username=\(query)"
        guard let url = URL(string: urlString) else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        if let token = KeychainHelper.get(forKey: "accessToken") {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        URLSession.shared.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: [UserProfile].self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    print("Ошибка поиска пользователей: \(error.localizedDescription)")
                    PostHogSDK.shared.capture("calendar_user_search_failed", properties: [
                        "query": query,
                        "error": error.localizedDescription
                    ])
                }
            }, receiveValue: { [weak self] users in
                self?.searchResults = users
                PostHogSDK.shared.capture("calendar_user_search_results", properties: [
                    "query": query,
                    "result_count": users.count
                ])
            })
            .store(in: &cancellables)
    }

    func clearResults() {
        searchResults = []
        PostHogSDK.shared.capture("calendar_user_search_cleared")
    }
}
