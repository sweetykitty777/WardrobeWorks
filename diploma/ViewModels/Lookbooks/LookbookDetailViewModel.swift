import Foundation
import Combine
import PostHog

class LookbookDetailViewModel: ObservableObject {
    @Published var outfits: [OutfitResponse] = []
    @Published var errorMessage: String?
    var wardrobeId: Int?
    var lookbookId: Int?

    private var cancellables = Set<AnyCancellable>()

    func fetchOutfits(in lookbookId: Int) {
        WardrobeService.shared.fetchLookbookOutfits(lookbookId: lookbookId) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let outfits):
                    self.outfits = outfits.sorted { lhs, rhs in
                        switch (lhs.createdAt, rhs.createdAt) {
                        case let (l?, r?): return l > r
                        case (_?, nil):    return true
                        case (nil, _?):    return false
                        default:           return false
                        }
                    }

                    PostHogSDK.shared.capture("lookbook outfits loaded", properties: [
                        "lookbook_id": lookbookId,
                        "count": outfits.count
                    ])

                case .failure(let error):
                    self.errorMessage = error.localizedDescription

                    PostHogSDK.shared.capture("lookbook outfits load failed", properties: [
                        "lookbook_id": lookbookId,
                        "error": error.localizedDescription
                    ])
                }
            }
        }
    }

    func removeOutfit(outfitId: Int) {
        guard let lookbookId = lookbookId else { return }

        WardrobeService.shared.removeOutfit(from: lookbookId, outfitId: outfitId) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self.outfits.removeAll { $0.id == outfitId }

                    PostHogSDK.shared.capture("lookbook outfit removed", properties: [
                        "lookbook_id": lookbookId,
                        "outfit_id": outfitId
                    ])

                case .failure(let error):
                    self.errorMessage = "Ошибка удаления аутфита: \(error.localizedDescription)"

                    PostHogSDK.shared.capture("lookbook outfit remove failed", properties: [
                        "lookbook_id": lookbookId,
                        "outfit_id": outfitId,
                        "error": error.localizedDescription
                    ])

                    print("Ошибка удаления аутфита из лукбука:", error)
                }
            }
        }
    }

    private static var customDecoder: JSONDecoder {
        let decoder = JSONDecoder()
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let dateStr = try container.decode(String.self)
            if let date = formatter.date(from: dateStr) {
                return date
            } else {
                throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid date format: \(dateStr)")
            }
        }
        return decoder
    }
}

