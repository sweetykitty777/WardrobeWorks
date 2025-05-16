//
//  ContentService.swift
//  diploma
//
//  Created by Olga on 22.04.2025.
//
/*
import Foundation

class ContentService {
    static let shared = ContentService()

    func fetchAll(completion: @escaping (
        _ types: [ClothingContentItem],
        _ brands: [ClothingContentItem],
        _ colors: [ClothingColor],
        _ seasons: [ClothingContentItem]
    ) -> Void) {
        let group = DispatchGroup()

        var types: [ClothingContentItem] = []
        var brands: [ClothingContentItem] = []
        var colors: [ClothingColor] = []
        var seasons: [ClothingContentItem] = []

        group.enter()
        WardrobeService.shared.fetchClothingTypes { result in
            if case .success(let data) = result {
                types = data
            }
            group.leave()
        }

        group.enter()
        WardrobeService.shared.fetchBrands { result in
            if case .success(let data) = result {
                brands = data
            }
            group.leave()
        }

        group.enter()
        WardrobeService.shared.fetchColors { result in
            if case .success(let data) = result {
                colors = data
            }
            group.leave()
        }

        group.enter()
        WardrobeService.shared.fetchSeasons { result in
            if case .success(let data) = result {
                seasons = data
            }
            group.leave()
        }

        group.notify(queue: .main) {
            completion(types, brands, colors, seasons)
        }
    }
}
*/
