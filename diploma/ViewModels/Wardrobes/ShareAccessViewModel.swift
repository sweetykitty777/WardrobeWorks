import Foundation
import Combine
import PostHog
import os

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
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "com.yourapp.identifier", category: "Access")

    init(wardrobeId: Int) {
        self.wardrobeId = wardrobeId
        loadSharedAccesses()
    }

    func loadSharedAccesses() {
        WardrobeService.shared.fetchAccessList { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }

                switch result {
                case .success(let accesses):
                    self.sharedAccesses = accesses.filter { $0.wardrobeId == self.wardrobeId }
                    self.fetchUserProfilesForAccesses()

                    PostHogSDK.shared.capture("access list loaded", properties: [
                        "wardrobe_id": self.wardrobeId,
                        "count": self.sharedAccesses.count
                    ])
                    self.logger.info("Access list loaded")

                case .failure(let error):
                    self.errorMessage = "Ошибка загрузки доступов: \(error.localizedDescription)"

                    PostHogSDK.shared.capture("access list load failed", properties: [
                        "wardrobe_id": self.wardrobeId,
                        "error": error.localizedDescription
                    ])
                    self.logger.error("Access list load failed: \(error.localizedDescription, privacy: .public)")
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

        SocialService.shared.searchUsers(byUsername: query) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }

                switch result {
                case .success(let users):
                    self.searchResults = users
                    PostHogSDK.shared.capture("user search performed", properties: [
                        "query": query,
                        "result_count": users.count
                    ])
                    self.logger.info("Search returned \(users.count) users")

                case .failure(let error):
                    self.errorMessage = "Ошибка поиска пользователей: \(error.localizedDescription)"
                    PostHogSDK.shared.capture("user search failed", properties: [
                        "query": query,
                        "error": error.localizedDescription
                    ])
                    self.logger.error("Search failed: \(error.localizedDescription, privacy: .public)")
                }
            }
        }
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
                guard let self = self else { return }

                switch result {
                case .success:
                    self.loadSharedAccesses()
                    self.searchText = ""
                    self.selectedUser = nil

                    PostHogSDK.shared.capture("access granted", properties: [
                        "wardrobe_id": self.wardrobeId,
                        "to_user_id": selectedUser.id,
                        "access_level": level.rawValue
                    ])
                    self.logger.info("Access granted to user \(selectedUser.id)")

                case .failure(let error):
                    self.errorMessage = "Ошибка выдачи доступа: \(error.localizedDescription)"
                    PostHogSDK.shared.capture("access grant failed", properties: [
                        "wardrobe_id": self.wardrobeId,
                        "to_user_id": selectedUser.id,
                        "access_level": level.rawValue,
                        "error": error.localizedDescription
                    ])
                    self.logger.error("Grant failed: \(error.localizedDescription, privacy: .public)")
                }
            }
        }
    }

    func removeSharedAccess(at offsets: IndexSet) {
        for index in offsets {
            let access = sharedAccesses[index]
            WardrobeService.shared.revokeAccess(accessId: access.id) { [weak self] result in
                DispatchQueue.main.async {
                    guard let self = self else { return }

                    switch result {
                    case .success:
                        self.sharedAccesses.remove(at: index)
                        self.userProfilesById.removeValue(forKey: access.grantedToUserId)

                        PostHogSDK.shared.capture("access revoked", properties: [
                            "wardrobe_id": self.wardrobeId,
                            "access_id": access.id,
                            "to_user_id": access.grantedToUserId
                        ])
                        self.logger.info("🗑️ Access revoked")

                    case .failure(let error):
                        self.errorMessage = "Ошибка удаления доступа: \(error.localizedDescription)"

                        PostHogSDK.shared.capture("access revoke failed", properties: [
                            "wardrobe_id": self.wardrobeId,
                            "access_id": access.id,
                            "to_user_id": access.grantedToUserId,
                            "error": error.localizedDescription
                        ])
                        self.logger.error("Revoke failed: \(error.localizedDescription, privacy: .public)")
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
                SocialService.shared.fetchUserById(access.grantedToUserId) { [weak self] result in
                    DispatchQueue.main.async {
                        guard let self = self else { return }

                        switch result {
                        case .success(let profile):
                            self.userProfilesById[profile.id] = profile
                        case .failure(let error):
                            self.logger.error("Failed to load user \(access.grantedToUserId): \(error.localizedDescription, privacy: .public)")
                        }
                    }
                }
            }
        }
    }
}
