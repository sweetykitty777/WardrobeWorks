//  WardrobeServiceContent.swift
//  diploma
//
//  Created by Olga on 04.05.2025.

import Foundation

extension WardrobeService {

    func fetchClothingTypes(completion: @escaping (Result<[ClothingContentItem], Error>) -> Void) {
        api.request(
            path: "/wardrobe-service/content/types",
            method: "GET",
            decodeTo: [ClothingContentItem].self,
            completion: completion
        )
    }

    func fetchSeasons(completion: @escaping (Result<[ClothingContentItem], Error>) -> Void) {
        api.request(
            path: "/wardrobe-service/content/seasons",
            method: "GET",
            decodeTo: [ClothingContentItem].self,
            completion: completion
        )
    }

    func fetchBrands(completion: @escaping (Result<[ClothingContentItem], Error>) -> Void) {
        api.request(
            path: "/wardrobe-service/content/brands",
            method: "GET",
            decodeTo: [ClothingContentItem].self,
            completion: completion
        )
    }

    func fetchColors(completion: @escaping (Result<[ClothingColor], Error>) -> Void) {
        api.request(
            path: "/wardrobe-service/content/colours",
            method: "GET",
            decodeTo: [ClothingColor].self,
            completion: completion
        )
    }
}
