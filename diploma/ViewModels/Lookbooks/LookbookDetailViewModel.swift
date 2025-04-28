import Foundation
import Combine

class LookbookDetailViewModel: ObservableObject {
    @Published var outfits: [OutfitResponse] = []
    @Published var errorMessage: String?
    var wardrobeId: Int?

    private var cancellables = Set<AnyCancellable>()

    func fetchOutfits(in lookbookId: Int) {
        guard let url = URL(string: "https://gate-acidnaya.amvera.io/api/v1/wardrobe-service/lookbooks/\(lookbookId)/outfits") else {
            errorMessage = "Неверный URL"
            return
        }
        var req = URLRequest(url: url)
        req.httpMethod = "GET"
        if let token = KeychainHelper.get(forKey: "accessToken") {
            req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        URLSession.shared.dataTaskPublisher(for: req)
            .map(\.data)
            .decode(type: [OutfitResponse].self, decoder: Self.customDecoder)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                if case let .failure(err) = completion {
                    self.errorMessage = err.localizedDescription
                    print("Ошибка фетчинга аутфитов:", err)
                }
            } receiveValue: { outfits in
                self.outfits = outfits.sorted(by: { lhs, rhs in
                    guard let lhsDate = lhs.createdAt, let rhsDate = rhs.createdAt else {
                        return lhs.createdAt != nil // outfit с датой идет раньше
                    }
                    return lhsDate > rhsDate // новее — выше
                })
                print("Загружено и отсортировано аутфитов: \(self.outfits.count)")
            }
            .store(in: &cancellables)
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
