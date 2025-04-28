//
//  UserCalendarSearchViewModel.swift
//  diploma
//
//  Created by Olga on 27.04.2025.
//

import Foundation
import Combine

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
                }
            }, receiveValue: { [weak self] users in
                self?.searchResults = users
            })
            .store(in: &cancellables)
    }
    
    func clearResults() {
        searchResults = []
    }
}
