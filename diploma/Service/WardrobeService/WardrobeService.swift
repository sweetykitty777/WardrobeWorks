import Foundation

final class WardrobeService {
    static let shared = WardrobeService()
    let api = ApiClient.shared
    private init() {}

    let cacheDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    let cacheTTL: TimeInterval = 3600 // 1 час

    let wardrobeCache = WardrobeCache()

    private func cacheURL(for key: String) -> URL {
        return cacheDirectory.appendingPathComponent("wardrobe_\(key).json")
    }

    func saveCache<T: Encodable>(_ data: T, for key: String) {
        let url = cacheURL(for: key)
        do {
            let encoded = try JSONEncoder().encode(data)
            try encoded.write(to: url)
        } catch {
            print("Ошибка при сохранении кэша: \(error)")
        }
    }

    func loadCache<T: Decodable>(for key: String) -> T? {
        let url = cacheURL(for: key)
        do {
            let data = try Data(contentsOf: url)
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            print("Ошибка чтения кэша: \(error)")
            return nil
        }
    }
}
