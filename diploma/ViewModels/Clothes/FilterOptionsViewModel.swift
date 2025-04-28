//
//  FilterOptionsViewModel.swift
//  diploma
//
//  Created by Olga on 23.04.2025.
//

import Foundation
import SwiftUI

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
                case .failure:
                    self.categories = []
                }
            }
        }

        WardrobeService.shared.fetchBrands { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let items):
                    self.brands = items.map { $0.name }
                case .failure:
                    self.brands = []
                }
            }
        }

        WardrobeService.shared.fetchColors { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let items):
                    self.colors = items.map { $0.name }
                case .failure:
                    self.colors = []
                }
            }
        }

        WardrobeService.shared.fetchSeasons { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let items):
                    self.seasons = items.map { $0.name }
                case .failure:
                    self.seasons = []
                }
            }
        }
    }
}
