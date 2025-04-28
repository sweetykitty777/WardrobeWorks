//
//  FollowListViewModel.swift
//  diploma
//
//  Created by Olga on 24.04.2025.
//

import Foundation
import Combine

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
        
        print(endpoint)

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        if let token = KeychainHelper.get(forKey: "accessToken") {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        print("GET \(url.absoluteString)")
        isLoading = true

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                self.isLoading = false

                if let error = error {
                    self.errorMessage = error.localizedDescription
                    print("Network error fetching \(endpoint):", error)
                    return
                }

                guard let http = response as? HTTPURLResponse else {
                    self.errorMessage = "Invalid response"
                    print("No HTTP response for \(endpoint)")
                    return
                }
                print("Response status code for \(endpoint):", http.statusCode)

                guard let data = data else {
                    self.errorMessage = "No data received"
                    print("No data in response for \(endpoint)")
                    return
                }

                // Выводим сырой JSON-тело
                if let raw = String(data: data, encoding: .utf8) {
                    print("Raw response for \(endpoint):\n\(raw)")
                } else {
                    print("Raw response for \(endpoint): <non-UTF8 data, \(data.count) bytes>")
                }

                do {
                    let users = try JSONDecoder().decode([UserPreview].self, from: data)
                    self.users = users
                    print("Decoded \(users.count) users for \(endpoint)")
                } catch {
                    self.errorMessage = "Decode error: \(error.localizedDescription)"
                    print("JSON decode error for \(endpoint):", error)
                }
            }
        }
        .resume()
    }
}
