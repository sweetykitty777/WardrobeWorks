import Foundation
import Combine
import UIKit

class UserProfileViewModel: ObservableObject {
    @Published var user: UserProfile = UserProfile(id: 0, username: "", bio: nil, avatar: nil)
    @Published var posts: [Post] = []
    @Published var publicItems: [ClothItem] = []
    @Published var publicOutfits: [OutfitResponse] = []
    @Published var publicLookbooks: [LookbookResponse] = []

    @Published var selectedImage: UIImage?
    @Published var showingImagePicker = false

    func loadUserProfile() {
        UserProfileService.shared.fetchProfile { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let user):
                    self.user = user
                    self.fetchUserPosts(userId: user.id)
                    self.fetchPublicItems()
                    self.fetchPublicOutfits()
                    self.fetchPublicLookbooks()
                case .failure(let error):
                    print("Ошибка загрузки профиля: \(error)")
                }
            }
        }
    }

    func fetchUserPosts(userId: Int) {
        PostService.shared.fetchUserPosts(userId: userId) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let posts):
                    self.posts = posts
                case .failure(let error):
                    print("Ошибка загрузки постов: \(error)")
                }
            }
        }
    }

    func fetchPublicItems() {
        WardrobeService.shared.fetchWardrobes { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let wardrobes):
                    for wardrobe in wardrobes {
                        WardrobeService.shared.fetchClothes(for: wardrobe.id) { result in
                            if case .success(let clothes) = result {
                                DispatchQueue.main.async {
                                    self.publicItems.append(contentsOf: clothes)
                                }
                            }
                        }
                    }
                case .failure(let error):
                    print("Ошибка загрузки гардеробов: \(error)")
                }
            }
        }
    }

    func fetchPublicOutfits() {
        WardrobeService.shared.fetchWardrobes { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let wardrobes):
                    for wardrobe in wardrobes {
                        OutfitService.shared.fetchOutfits(for: wardrobe.id) { result in
                            if case .success(let outfits) = result {
                                DispatchQueue.main.async {
                                    self.publicOutfits.append(contentsOf: outfits)
                                }
                            }
                        }
                    }
                case .failure(let error):
                    print("Ошибка загрузки гардеробов: \(error)")
                }
            }
        }
    }

    private func fetchPublicLookbooks() {
        WardrobeService.shared.fetchWardrobes { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let wardrobes):
                    for wardrobe in wardrobes {
                        LookbookService.shared.fetchLookbooks(for: wardrobe.id) { result in
                            if case .success(let lb) = result {
                                DispatchQueue.main.async {
                                    self.publicLookbooks.append(contentsOf: lb)
                                }
                            }
                        }
                    }
                case .failure(let error):
                    print("Ошибка загрузки гардеробов: \(error)")
                }
            }
        }
    }

    func updateBio(_ newBio: String, completion: @escaping (Result<Void, Error>) -> Void) {
        UserProfileService.shared.updateBio(newBio) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self.user.bio = newBio
                    completion(.success(()))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }

    func updateAvatar(_ newUrl: String, completion: @escaping (Result<Void, Error>) -> Void) {
        UserProfileService.shared.updateAvatar(newUrl) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self.user.avatar = newUrl
                    completion(.success(()))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }

    private func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        let newSize = widthRatio > heightRatio
            ? CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
            : CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)

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
        ImageUploadService.shared.uploadImage(resized) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let url):
                    print("✅ Image uploaded: \(url)")
                    completion(.success(url))
                case .failure(let error):
                    print("❌ Image upload failed: \(error)")
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
}
