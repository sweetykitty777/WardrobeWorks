import Foundation
import Combine
import PostHog

class OtherUserProfileViewModel: ObservableObject {
    @Published var user: UserProfile = UserProfile(id: 0, username: "", bio: nil, avatar: nil)
    @Published var posts: [Post] = []
    @Published var publicItems: [ClothItem] = []
    @Published var publicOutfits: [OutfitResponse] = []
    @Published var publicLookbooks: [LookbookResponse] = []

    @Published var isFollowing: Bool = false
    @Published var loadingFollowState: Bool = false

    private var cancellables = Set<AnyCancellable>()

    func loadProfile(for userId: Int) {
        PostHogSDK.shared.capture("other_profile_opened", properties: ["user_id": userId])
        fetchUser(userId: userId)
        fetchUserPosts(userId: userId)
        fetchWardrobesAndContent(for: userId)
        checkFollowing(followedId: userId)
    }

    private func fetchUser(userId: Int) {
        SocialService.shared.fetchUserById(userId) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let user):
                    self.user = user
                    PostHogSDK.shared.capture("other_profile_loaded", properties: ["user_id": user.id])
                case .failure(let error):
                    PostHogSDK.shared.capture("other_profile_load_failed", properties: ["user_id": userId, "error": error.localizedDescription])
                }
            }
        }
    }

    private func fetchUserPosts(userId: Int) {
        SocialService.shared.fetchUserPosts(userId: userId) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let posts):
                    self.posts = posts
                    PostHogSDK.shared.capture("other_user_posts_loaded", properties: ["user_id": userId, "count": posts.count])
                case .failure(let error):
                    print("Ошибка загрузки постов:", error)
                }
            }
        }
    }

    private func fetchWardrobesAndContent(for userId: Int) {
        WardrobeService.shared.getWardrobes(of: userId) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let wardrobes):
                    PostHogSDK.shared.capture("other_user_wardrobes_loaded", properties: ["user_id": userId, "count": wardrobes.count])
                    for wardrobe in wardrobes {
                        self.loadContent(for: wardrobe.id)
                    }
                case .failure(let error):
                    print("Ошибка загрузки гардеробов:", error)
                }
            }
        }
    }

    private func loadContent(for wardrobeId: Int) {
        WardrobeService.shared.fetchClothes(for: wardrobeId) { clothesResult in
            if case let .success(clothes) = clothesResult {
                DispatchQueue.main.async {
                    let existingIds = Set(self.publicItems.map { $0.id })
                    let uniqueClothes = clothes.filter { !existingIds.contains($0.id) }
                    self.publicItems.append(contentsOf: uniqueClothes)
                    PostHogSDK.shared.capture("other_user_clothes_loaded", properties: ["wardrobe_id": wardrobeId, "count": uniqueClothes.count])
                }
            }
        }

        WardrobeService.shared.fetchOutfits(for: wardrobeId) { outfitsResult in
            if case let .success(outfits) = outfitsResult {
                DispatchQueue.main.async {
                    let existingIds = Set(self.publicOutfits.map { $0.id })
                    let uniqueOutfits = outfits.filter { !existingIds.contains($0.id) }
                    self.publicOutfits.append(contentsOf: uniqueOutfits)
                    PostHogSDK.shared.capture("other_user_outfits_loaded", properties: ["wardrobe_id": wardrobeId, "count": uniqueOutfits.count])
                }
            }
        }

        WardrobeService.shared.fetchLookbooks(for: wardrobeId) { lookbookResult in
            if case let .success(lookbooks) = lookbookResult {
                DispatchQueue.main.async {
                    let existingIds = Set(self.publicLookbooks.map { $0.id })
                    let uniqueLookbooks = lookbooks.filter { !existingIds.contains($0.id) }
                    self.publicLookbooks.append(contentsOf: uniqueLookbooks)
                    PostHogSDK.shared.capture("other_user_lookbooks_loaded", properties: ["wardrobe_id": wardrobeId, "count": uniqueLookbooks.count])
                }
            }
        }
    }

    func checkFollowing(followedId: Int) {
        loadingFollowState = true
        SocialService.shared.isFollowing(userId: followedId) { isFollowing in
            DispatchQueue.main.async {
                self.loadingFollowState = false
                self.isFollowing = isFollowing
            }
        }
    }

    func follow(followedId: Int) {
        loadingFollowState = true
        SocialService.shared.follow(userId: followedId) { success in
            DispatchQueue.main.async {
                self.loadingFollowState = false
                if success {
                    self.isFollowing = true
                    PostHogSDK.shared.capture("user_followed", properties: ["followed_id": followedId])
                }
            }
        }
    }

    func unfollow(followedId: Int) {
        loadingFollowState = true
        SocialService.shared.unfollow(userId: followedId) { success in
            DispatchQueue.main.async {
                self.loadingFollowState = false
                if success {
                    self.isFollowing = false
                    PostHogSDK.shared.capture("user_unfollowed", properties: ["unfollowed_id": followedId])
                }
            }
        }
    }
}
