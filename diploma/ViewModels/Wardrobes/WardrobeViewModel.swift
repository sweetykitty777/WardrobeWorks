import Foundation
import PostHog
import os

class WardrobeViewModel: ObservableObject {
    @Published var wardrobes: [UsersWardrobe] = []
    @Published var selectedWardrobe: UsersWardrobe?

    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "com.yourapp.identifier", category: "Wardrobe")

    func fetchWardrobes() {
        WardrobeService.shared.fetchWardrobes { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let wardrobes):
                    self.wardrobes = wardrobes

                    PostHogSDK.shared.capture("wardrobes fetched", properties: [
                        "count": wardrobes.count
                    ])
                    self.logger.info("Fetched \(wardrobes.count) wardrobes")

                case .failure(let error):
                    PostHogSDK.shared.capture("wardrobe fetch failed", properties: [
                        "error": error.localizedDescription
                    ])
                    self.logger.error("Failed to fetch wardrobes: \(error.localizedDescription, privacy: .public)")
                }
            }
        }
    }

    func fetchWardrobes(of userId: Int) {
        WardrobeService.shared.getWardrobes(of: userId) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let list):
                    self.wardrobes = list

                    PostHogSDK.shared.capture("external wardrobes fetched", properties: [
                        "user_id": userId,
                        "count": list.count
                    ])
                    self.logger.info("Fetched \(list.count) wardrobes for user \(userId)")

                case .failure(let error):
                    PostHogSDK.shared.capture("external wardrobe fetch failed", properties: [
                        "user_id": userId,
                        "error": error.localizedDescription
                    ])
                    self.logger.error("Failed to fetch wardrobes of user \(userId): \(error.localizedDescription, privacy: .public)")
                }
            }
        }
    }

    func fetchWardrobe(by id: Int) {
        WardrobeService.shared.getWardrobe(by: id) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let wardrobe):
                    self.selectedWardrobe = wardrobe

                    PostHogSDK.shared.capture("wardrobe selected", properties: [
                        "wardrobe_id": id,
                        "name": wardrobe.name
                    ])
                    self.logger.info("Selected wardrobe \(id)")

                case .failure(let error):
                    PostHogSDK.shared.capture("wardrobe fetch failed", properties: [
                        "wardrobe_id": id,
                        "error": error.localizedDescription
                    ])
                    self.logger.error("Failed to fetch wardrobe \(id): \(error.localizedDescription, privacy: .public)")
                }
            }
        }
    }

    func removeWardrobe(id: Int, completion: @escaping () -> Void) {
        WardrobeService.shared.removeWardrobe(id: id) { result in
            DispatchQueue.main.async {
                switch result {
                case .success():
                    self.wardrobes.removeAll { $0.id == id }
                    PostHogSDK.shared.capture("wardrobe deleted", properties: [
                        "wardrobe_id": id
                    ])
                    self.logger.info("Deleted wardrobe \(id)")
                    completion()

                case .failure(let error):
                    PostHogSDK.shared.capture("wardrobe delete failed", properties: [
                        "wardrobe_id": id,
                        "error": error.localizedDescription
                    ])
                    self.logger.error("Failed to delete wardrobe \(id): \(error.localizedDescription, privacy: .public)")
                }
            }
        }
    }

    func createWardrobe(name: String, isPrivate: Bool, completion: @escaping () -> Void) {
        let request = CreateWardrobeRequest(
            name: name,
            description: "default",
            isPrivate: isPrivate
        )

        WardrobeService.shared.createWardrobe(request: request) { result in
            DispatchQueue.main.async {
                switch result {
                case .success():
                    self.fetchWardrobes()
                    PostHogSDK.shared.capture("wardrobe created", properties: [
                        "name": name,
                        "is_private": isPrivate
                    ])
                    self.logger.info("Created wardrobe: \(name) (private: \(isPrivate))")
                    completion()

                case .failure(let error):
                    PostHogSDK.shared.capture("wardrobe create failed", properties: [
                        "name": name,
                        "is_private": isPrivate,
                        "error": error.localizedDescription
                    ])
                    self.logger.error("Failed to create wardrobe \(name): \(error.localizedDescription, privacy: .public)")
                }
            }
        }
    }
}
