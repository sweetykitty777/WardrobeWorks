import Foundation
import Combine
import PostHog

class FollowListViewModel: ObservableObject {
    @Published var users: [UserPreview] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private var cancellables = Set<AnyCancellable>()

    func fetchFollowers() {
        fetch(from: "follow/followers")
    }

    func fetchFollowings() {
        fetch(from: "follow/followings")
    }

    private func fetch(from endpoint: String) {
        guard let url = URL(string: "https://gate-acidnaya.amvera.io/api/v1/social-service/\(endpoint)") else {
            print("Invalid URL for endpoint: \(endpoint)")
            return
        }

        PostHogSDK.shared.capture("follow_list_fetch_started", properties: ["endpoint": endpoint])

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        if let token = KeychainHelper.get(forKey: "accessToken") {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        isLoading = true

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                self.isLoading = false

                if let error = error {
                    self.errorMessage = error.localizedDescription
                    PostHogSDK.shared.capture("follow_list_fetch_failed", properties: [
                        "endpoint": endpoint,
                        "error": error.localizedDescription
                    ])
                    return
                }

                guard let http = response as? HTTPURLResponse else {
                    self.errorMessage = "Invalid response"
                    PostHogSDK.shared.capture("follow_list_fetch_failed", properties: [
                        "endpoint": endpoint,
                        "error": "Invalid response"
                    ])
                    return
                }

                guard let data = data else {
                    self.errorMessage = "No data received"
                    PostHogSDK.shared.capture("follow_list_fetch_failed", properties: [
                        "endpoint": endpoint,
                        "error": "No data"
                    ])
                    return
                }

                do {
                    let users = try JSONDecoder().decode([UserPreview].self, from: data)
                    self.users = users
                    PostHogSDK.shared.capture("follow_list_fetch_success", properties: [
                        "endpoint": endpoint,
                        "users_count": users.count
                    ])
                } catch {
                    self.errorMessage = "Decode error: \(error.localizedDescription)"
                    PostHogSDK.shared.capture("follow_list_fetch_failed", properties: [
                        "endpoint": endpoint,
                        "error": "Decode error: \(error.localizedDescription)"
                    ])
                }
            }
        }.resume()
    }
}
