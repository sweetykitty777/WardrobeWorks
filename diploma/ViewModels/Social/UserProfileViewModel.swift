import Foundation
import Combine
import UIKit
import PostHog

class UserProfileViewModel: ObservableObject {
    @Published var user: UserProfile = UserProfile(id: 0, username: "", bio: nil, avatar: nil)
    @Published var posts: [Post] = []
    @Published var publicItems: [ClothItem] = []
    @Published var publicOutfits: [OutfitResponse] = []
    @Published var publicLookbooks: [LookbookResponse] = []

    @Published var selectedImage: UIImage?
    @Published var showingImagePicker = false

    func loadUserProfile() {
        SocialService.shared.fetchCurrentUser { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let user):
                    self.user = user
                    PostHogSDK.shared.capture("profile_loaded", properties: ["user_id": user.id])
                    self.fetchUserPosts(userId: user.id)
                    self.fetchPublicContent()
                case .failure(let error):
                    print("Ошибка загрузки профиля: \(error)")
                    PostHogSDK.shared.capture("profile_load_failed", properties: ["error": error.localizedDescription])
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
                    PostHogSDK.shared.capture("user_posts_loaded", properties: ["count": posts.count])
                case .failure(let error):
                    print("Ошибка загрузки постов: \(error)")
                    PostHogSDK.shared.capture("user_posts_load_failed", properties: ["error": error.localizedDescription])
                }
            }
        }
    }

    private func fetchPublicContent() {
        WardrobeService.shared.fetchWardrobes { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let wardrobes):
                    for wardrobe in wardrobes {
                        self.loadContent(for: wardrobe.id)
                    }
                case .failure(let error):
                    print("Ошибка загрузки гардеробов: \(error)")
                    PostHogSDK.shared.capture("wardrobes_load_failed", properties: ["error": error.localizedDescription])
                }
            }
        }
    }

    private func loadContent(for wardrobeId: Int) {
        WardrobeService.shared.fetchClothes(for: wardrobeId) { result in
            if case let .success(clothes) = result {
                DispatchQueue.main.async {
                    let existingIds = Set(self.publicItems.map { $0.id })
                    let newItems = clothes.filter { !existingIds.contains($0.id) }
                    self.publicItems.append(contentsOf: newItems)
                    PostHogSDK.shared.capture("public_clothes_loaded", properties: ["count": newItems.count])
                }
            }
        }

        WardrobeService.shared.fetchOutfits(for: wardrobeId) { result in
            if case let .success(outfits) = result {
                DispatchQueue.main.async {
                    let existingIds = Set(self.publicOutfits.map { $0.id })
                    let newOutfits = outfits.filter { !existingIds.contains($0.id) }
                    self.publicOutfits.append(contentsOf: newOutfits)
                    PostHogSDK.shared.capture("public_outfits_loaded", properties: ["count": newOutfits.count])
                }
            }
        }

        WardrobeService.shared.fetchLookbooks(for: wardrobeId) { result in
            if case let .success(lookbooks) = result {
                DispatchQueue.main.async {
                    let existingIds = Set(self.publicLookbooks.map { $0.id })
                    let newLookbooks = lookbooks.filter { !existingIds.contains($0.id) }
                    self.publicLookbooks.append(contentsOf: newLookbooks)
                    PostHogSDK.shared.capture("public_lookbooks_loaded", properties: ["count": newLookbooks.count])
                }
            }
        }
    }

    func updateBio(_ newBio: String, completion: @escaping (Result<Void, Error>) -> Void) {
        SocialService.shared.updateBio(newBio) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self.user.bio = newBio
                    PostHogSDK.shared.capture("bio_updated")
                    completion(.success(()))
                case .failure(let error):
                    completion(.failure(error))
                    PostHogSDK.shared.capture("bio_update_failed", properties: ["error": error.localizedDescription])
                }
            }
        }
    }

    func updateAvatar(_ newUrl: String, completion: @escaping (Result<Void, Error>) -> Void) {
        SocialService.shared.updateAvatar(newUrl) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self.user.avatar = newUrl
                    PostHogSDK.shared.capture("avatar_updated")
                    completion(.success(()))
                case .failure(let error):
                    PostHogSDK.shared.capture("avatar_update_failed", properties: ["error": error.localizedDescription])
                    completion(.failure(error))
                }
            }
        }
    }

    private func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        let widthRatio = targetSize.width / size.width
        let heightRatio = targetSize.height / size.height
        let newSize = widthRatio > heightRatio
            ? CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
            : CGSize(width: size.width * widthRatio, height: size.height * widthRatio)

        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: CGRect(origin: .zero, size: newSize))
        let resized = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return resized ?? image
    }

    func uploadAvatarIfNeeded(completion: @escaping (Result<String?, Error>) -> Void) {
        guard let image = selectedImage else {
            completion(.success(nil))
            return
        }

        let resized = resizeImage(image: image, targetSize: CGSize(width: 100, height: 100))
        WardrobeService.shared.uploadImage(resized) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let url):
                    PostHogSDK.shared.capture("avatar_uploaded")
                    completion(.success(url))
                case .failure(let error):
                    PostHogSDK.shared.capture("avatar_upload_failed", properties: ["error": error.localizedDescription])
                    completion(.failure(error))
                }
            }
        }
    }

    func uploadAndUpdateAvatar(completion: @escaping (Result<Void, Error>) -> Void) {
        uploadAvatarIfNeeded { result in
            switch result {
            case .success(let url):
                if let url = url {
                    self.updateAvatar(url, completion: completion)
                } else {
                    completion(.success(()))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    func deletePost(postId: Int) {
        SocialService.shared.deletePost(id: postId) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self.posts.removeAll { $0.id == postId }
                    PostHogSDK.shared.capture("post_deleted", properties: ["post_id": postId])
                case .failure(let error):
                    PostHogSDK.shared.capture("post_delete_failed", properties: ["post_id": postId, "error": error.localizedDescription])
                    print("Ошибка удаления поста: \(error)")
                }
            }
        }
    }

    func editPostText(postId: Int, newText: String, completion: @escaping (Result<Void, Error>) -> Void) {
        SocialService.shared.updatePostText(id: postId, newText: newText) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    if let index = self.posts.firstIndex(where: { $0.id == postId }) {
                        self.posts[index].text = newText
                    }
                    PostHogSDK.shared.capture("post_text_updated", properties: ["post_id": postId])
                    completion(.success(()))
                case .failure(let error):
                    PostHogSDK.shared.capture("post_text_update_failed", properties: ["post_id": postId, "error": error.localizedDescription])
                    completion(.failure(error))
                }
            }
        }
    }
}
