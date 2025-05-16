//
//  WardrobeSelectionViewModel.swift
//  diploma
//
//  Created by Olga on 10.05.2025.
//
import SwiftUI

class WardrobeSelectionViewModel: ObservableObject {
    @Published var wardrobeItems: [ClothItem] = []
    @Published var selectedIds: Set<Int> = []
    @Published var showFilters = false

    @Published var selectedCategories: Set<String> = []
    @Published var selectedBrands: Set<String> = []
    @Published var selectedColors: Set<String> = []
    @Published var selectedSeasons: Set<String> = []
    @Published var selectedPriceRanges: Set<String> = []

    func fetchClothes(for wardrobeId: Int) {
        WardrobeService.shared.fetchClothes(for: wardrobeId) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let items):
                    self.wardrobeItems = items
                case .failure(let error):
                    print("Ошибка загрузки одежды: \(error)")
                }
            }
        }
    }

    func toggleSelection(for item: ClothItem) {
        if selectedIds.contains(item.id) {
            selectedIds.remove(item.id)
        } else {
            selectedIds.insert(item.id)
        }
    }

    var filteredItems: [ClothItem] {
        wardrobeItems.filter { item in
            (selectedCategories.isEmpty || selectedCategories.contains(item.category)) &&
            (selectedBrands.isEmpty || selectedBrands.contains(item.brandName ?? "")) &&
            (selectedColors.isEmpty || selectedColors.contains(item.colourName ?? "")) &&
            (selectedSeasons.isEmpty || selectedSeasons.contains(item.seasonName ?? "")) &&
            (selectedPriceRanges.isEmpty || selectedPriceRanges.contains("\(item.price ?? 0)"))
        }
    }
}
