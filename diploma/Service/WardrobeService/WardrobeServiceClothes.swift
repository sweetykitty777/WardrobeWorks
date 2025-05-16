//  WardrobeServiceClothes.swift
//  diploma
//
//  Created by Olga on 04.05.2025.

import Foundation

extension WardrobeService {
    
    func fetchClothes(for wardrobeId: Int, completion: @escaping (Result<[ClothItem], Error>) -> Void) {

        // Запрос к бэку
        api.request(
            path: "/wardrobe-service/clothes/\(wardrobeId)/all",
            method: "GET",
            decodeTo: [ClothItem].self
        ) { [weak self] result in
            if case .success(let clothes) = result {
                self?.wardrobeCache.cachedClothes[wardrobeId] = clothes
                self?.wardrobeCache.clothesFetchTime[wardrobeId] = Date()
            }
            completion(result)
        }
    }

    func createClothingItem(wardrobeId: Int, request payload: CreateClothingItemRequest, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let body = try? JSONEncoder().encode(payload) else {
            return completion(.failure(NSError(domain: "Encoding error", code: 500)))
        }

        api.requestVoid(
            path: "/wardrobe-service/clothes/\(wardrobeId)/create",
            method: "POST",
            body: body,
            completion: completion
        )
    }

    func updateClothingItem(id: Int, request payload: UpdateClothingItemRequest, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let body = try? JSONEncoder().encode(payload) else {
            return completion(.failure(NSError(domain: "Encoding error", code: 500)))
        }

        api.requestVoid(
            path: "/wardrobe-service/clothes/\(id)/update-features",
            method: "PATCH",
            body: body,
            completion: completion
        )
    }

    func deleteClothingItem(id: Int, completion: @escaping (Bool) -> Void) {
        api.requestVoid(
            path: "/wardrobe-service/clothes/\(id)",
            method: "DELETE"
        ) { result in
            switch result {
            case .success:
                completion(true)
            case .failure:
                completion(false)
            }
        }
    }

    func fetchClothesInOutfit(outfitId: Int, completion: @escaping (Result<[ClothItem], Error>) -> Void) {
        // Пока используется мок, заменить при наличии настоящего API
        let mockItems: [ClothItem] = [
            ClothItem(id: 1, description: "Белая футболка", imagePath: "https://via.placeholder.com/150", price: 1200, typeName: "Футболка", colourName: "Белый", seasonName: "Лето", brandName: "Uniqlo"),
            ClothItem(id: 2, description: "Джинсы", imagePath: "https://via.placeholder.com/150", price: 3500, typeName: "Джинсы", colourName: "Синий", seasonName: "Весна", brandName: "Levi's")
        ]

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            completion(.success(mockItems))
        }
    }

    func fetchOutfitsForClothing(id: Int, completion: @escaping (Result<[OutfitResponse], Error>) -> Void) {
        api.request(
            path: "/wardrobe-service/clothes/\(id)/outfits",
            method: "GET",
            decodeTo: [OutfitResponse].self,
            dateDecoding: true,
            completion: completion
        )
    }
    
    func copyItem(clothId: Int, to wardrobeId: Int, completion: @escaping (Result<Void, Error>) -> Void) {
        let path = "/wardrobe-service/clothes/\(clothId)/copy/\(wardrobeId)"
        api.requestVoid(
            path: path,
            method: "POST",
            completion: completion
        )
    }

}
