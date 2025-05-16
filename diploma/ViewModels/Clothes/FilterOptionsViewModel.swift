import Foundation
import SwiftUI
import PostHog

class FilterOptionsViewModel: ObservableObject {
    @Published var categories: [String] = []
    @Published var brands: [String] = []
    @Published var colors: [String] = []
    @Published var seasons: [String] = []
    @Published var priceRanges: [String] = ["До 1000 ₽", "1000-5000 ₽", "5000-10000 ₽", "10000+ ₽"]

    func fetchAll() {
        WardrobeService.shared.fetchClothingTypes { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let items):
                    self.categories = items.map { $0.name }
                    PostHogSDK.shared.capture("filter content loaded", properties: ["type": "categories", "count": items.count])
                case .failure(let error):
                    self.categories = []
                    PostHogSDK.shared.capture("filter content load failed", properties: ["type": "categories", "error": error.localizedDescription])
                }
            }
        }

        WardrobeService.shared.fetchBrands { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let items):
                    self.brands = items.map { $0.name }
                    PostHogSDK.shared.capture("filter content loaded", properties: ["type": "brands", "count": items.count])
                case .failure(let error):
                    self.brands = []
                    PostHogSDK.shared.capture("filter content load failed", properties: ["type": "brands", "error": error.localizedDescription])
                }
            }
        }

        WardrobeService.shared.fetchColors { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let items):
                    self.colors = items.map { $0.name }
                    PostHogSDK.shared.capture("filter content loaded", properties: ["type": "colors", "count": items.count])
                case .failure(let error):
                    self.colors = []
                    PostHogSDK.shared.capture("filter content load failed", properties: ["type": "colors", "error": error.localizedDescription])
                }
            }
        }

        WardrobeService.shared.fetchSeasons { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let items):
                    self.seasons = items.map { $0.name }
                    PostHogSDK.shared.capture("filter content loaded", properties: ["type": "seasons", "count": items.count])
                case .failure(let error):
                    self.seasons = []
                    PostHogSDK.shared.capture("filter content load failed", properties: ["type": "seasons", "error": error.localizedDescription])
                }
            }
        }
    }
}
