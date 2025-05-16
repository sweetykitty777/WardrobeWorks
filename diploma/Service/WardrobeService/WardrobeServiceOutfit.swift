//
//  WardrobeServiceOutfit.swift
//  diploma
//
//  Created by Olga on 04.05.2025.
//

import Foundation

extension WardrobeService {

    func createOutfit(payload: CreateOutfitRequest, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let body = try? JSONEncoder().encode(payload) else {
            return completion(.failure(NSError(domain: "Encoding error", code: 500)))
        }

        api.requestVoid(
            path: "/wardrobe-service/outfits/create",
            method: "POST",
            body: body,
            completion: completion
        )
    }
    
    func createOutfit(wardrobeId: Int, payload: FullOutfitEditRequest, completion: @escaping (Result<Void, Error>) -> Void) {
     /*   // Преобразуем FullOutfitEditRequest в CreateOutfitRequest
        let converted = CreateOutfitRequest(
            name: payload.name,
            description: payload.description,
            wardrobeId: wardrobeId,
            imagePath: payload.imagePath,
            clothes: payload.clothes
        )

        createOutfit(payload: converted, completion: completion)*/
    }

    func fetchOutfits(
        for wardrobeId: Int,
        completion: @escaping (Result<[OutfitResponse], Error>) -> Void
    ) {
        api.request(
            path: "/wardrobe-service/outfits/wardrobe=\(wardrobeId)/all",
            method: "GET",
            decodeTo: [OutfitResponse].self,
            dateDecoding: true
        ) { result in
            switch result {
            case .success(let outfits):
                print("Загружено с сервера: \(outfits.count) шт.")
                completion(.success(outfits))
            case .failure(let error):
                print("Ошибка загрузки с сервера: \(error)")
                completion(.failure(error))
            }
        }
    }



    func updateOutfitLayout(outfitId: Int, placedItems: [PlacedClothingItem], completion: @escaping (Result<Void, Error>) -> Void) {
        guard let body = try? JSONEncoder().encode(placedItems) else {
            return completion(.failure(NSError(domain: "Encoding error", code: 500)))
        }

        api.requestVoid(
            path: "/wardrobe-service/outfits/\(outfitId)/layout",
            method: "PUT",
            body: body,
            completion: completion
        )
    }

    func fetchOutfitClothes(outfitId: Int, completion: @escaping (Result<[ClothItem], Error>) -> Void) {
        api.request(
            path: "/wardrobe-service/outfits/\(outfitId)/clothes?outfitId=\(outfitId)",
            method: "GET",
            decodeTo: [ClothItem].self,
            completion: completion
        )
    }

    func deleteOutfit(id: Int, completion: @escaping (Result<Void, Error>) -> Void) {
        api.requestVoid(
            path: "/wardrobe-service/outfits/\(id)?outfitId=\(id)",
            method: "DELETE",
            completion: completion
        )
    }
    
    func fetchOutfit(id: Int, completion: @escaping (Result<OutfitResponse, Error>) -> Void) {
        api.request(
            path: "/wardrobe-service/outfits/\(id)?outfitId=\(id)",
            method: "GET",
            decodeTo: OutfitResponse.self,
            dateDecoding: true,
            completion: completion
        )
    }
    
    func fetchFullOutfit(id: Int, completion: @escaping (Result<FullOutfitResponse, Error>) -> Void) {
        api.request(
            path: "/wardrobe-service/outfits/\(id)/full?outfitId=\(id)",
            method: "GET",
            decodeTo: FullOutfitResponse.self,
            dateDecoding: true,
            completion: completion
        )
    }

    func updateOutfit(id: Int, payload: FullOutfitEditRequest, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let body = try? JSONEncoder().encode(payload) else {
            return completion(.failure(NSError(domain: "Encoding error", code: 500)))
        }

        api.requestVoid(
            path: "/wardrobe-service/outfits/\(id)/update",
            method: "PATCH",
            body: body,
            completion: completion
        )
    }

}
