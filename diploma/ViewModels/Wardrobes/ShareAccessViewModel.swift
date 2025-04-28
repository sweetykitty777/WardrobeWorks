//  ShareAccessViewModel.swift
//  diploma
//
//  Created by Olga on 21.04.2025.

import Foundation
import Combine

@MainActor
class ShareAccessViewModel: ObservableObject {
    @Published var sharedAccesses: [SharedAccess] = []
    @Published var errorMessage: String?

    @Published var searchText: String = ""
    @Published var searchResults: [UserProfile] = []
    @Published var selectedUser: UserProfile?

    @Published var userProfilesById: [Int: UserProfile] = [:]
    
    private var cancellables = Set<AnyCancellable>()
    private let wardrobeId: Int

    init(wardrobeId: Int) {
        self.wardrobeId = wardrobeId
        loadSharedAccesses()
    }

    func loadSharedAccesses() {
        WardrobeService.shared.fetchAccessList { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let accesses):
                    self?.sharedAccesses = accesses.filter { $0.wardrobeId == self?.wardrobeId }
                    self?.fetchUserProfilesForAccesses()
                case .failure(let error):
                    self?.errorMessage = "Ошибка загрузки доступов: \(error.localizedDescription)"
                }
            }
        }
    }

    func searchUsers() {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else {
            searchResults = []
            return
        }

        let urlString = "https://gate-acidnaya.amvera.io/api/v1/social-service/users/find/username=\(query)"
        guard let url = URL(string: urlString) else {
            print("searchUsers: invalid URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        if let token = KeychainHelper.get(forKey: "accessToken") {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        URLSession.shared.dataTaskPublisher(for: request)
            .map(\ .data)
            .decode(type: [UserProfile].self, decoder: JSONDecoder())
            .replaceError(with: [])
            .receive(on: DispatchQueue.main)
            .sink { [weak self] users in
                self?.searchResults = users
            }
            .store(in: &cancellables)
    }

    func addSharedAccess(level: AccessLevel) {
        guard let selectedUser = selectedUser else {
            errorMessage = "Выберите пользователя для выдачи доступа"
            return
        }

        WardrobeService.shared.grantAccess(
            wardrobeId: wardrobeId,
            grantedToUserId: selectedUser.id,
            accessType: level.rawValue
        ) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.loadSharedAccesses()
                    self?.searchText = ""
                    self?.selectedUser = nil
                case .failure(let error):
                    self?.errorMessage = "Ошибка выдачи доступа: \(error.localizedDescription)"
                }
            }
        }
    }

    func removeSharedAccess(at offsets: IndexSet) {
        for index in offsets {
            let access = sharedAccesses[index]
            WardrobeService.shared.revokeAccess(accessId: access.id) { [weak self] result in
                DispatchQueue.main.async {
                    switch result {
                    case .success:
                        self?.sharedAccesses.remove(at: index)
                        self?.userProfilesById.removeValue(forKey: access.grantedToUserId)
                    case .failure(let error):
                        self?.errorMessage = "Ошибка удаления доступа: \(error.localizedDescription)"
                    }
                }
            }
        }
    }

    func userById(_ id: Int) -> UserProfile? {
        return userProfilesById[id]
    }

    private func fetchUserProfilesForAccesses() {
        for access in sharedAccesses {
            if userProfilesById[access.grantedToUserId] == nil {
                fetchUserProfile(userId: access.grantedToUserId)
            }
        }
    }

    private func fetchUserProfile(userId: Int) {
        guard let url = URL(string: "https://gate-acidnaya.amvera.io/api/v1/social-service/users/\(userId)") else {
            print("fetchUserProfile: invalid URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        if let token = KeychainHelper.get(forKey: "accessToken") {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        URLSession.shared.dataTaskPublisher(for: request)
            .map(\ .data)
            .decode(type: UserProfile.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    print("Ошибка загрузки профиля пользователя \(userId): \(error.localizedDescription)")
                }
            }, receiveValue: { [weak self] userProfile in
                self?.userProfilesById[userId] = userProfile
                print("Профиль пользователя \(userId) загружен")
            })
            .store(in: &cancellables)
    }
}
