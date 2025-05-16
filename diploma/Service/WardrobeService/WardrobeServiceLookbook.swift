//
//  WardrobeServiceLookbook.swift
//  diploma
//
//  Created by Olga on 04.05.2025.
//

import Foundation

extension WardrobeService {

    func createLookbook(wardrobeId: Int, name: String, description: String = "", completion: @escaping (Result<Void, Error>) -> Void) {
        let payload = ["name": name, "description": description]
        guard let body = try? JSONEncoder().encode(payload) else {
            return completion(.failure(NSError(domain: "Encoding error", code: 500)))
        }

        api.requestVoid(
            path: "/wardrobe-service/lookbooks/\(wardrobeId)/create",
            method: "POST",
            body: body,
            completion: completion
        )
    }

    func fetchLookbooks(for wardrobeId: Int, completion: @escaping (Result<[LookbookResponse], Error>) -> Void) {
        api.request(
            path: "/wardrobe-service/lookbooks/wardrobe=\(wardrobeId)/all",
            method: "GET",
            decodeTo: [LookbookResponse].self,
            dateDecoding: true,
            completion: completion
        )
    }
    
    func fetchLookbookOutfits(
        lookbookId: Int,
        completion: @escaping (Result<[OutfitResponse], Error>) -> Void
    ) {
        api.request(
            path: "/wardrobe-service/lookbooks/\(lookbookId)/outfits",
            method: "GET",
            decodeTo: [OutfitResponse].self,
            dateDecoding: true,
            completion: completion
        )
    }

    func addOutfit(to lookbookId: Int, outfitId: Int, completion: @escaping (Result<Void, Error>) -> Void) {
        api.requestVoid(
            path: "/wardrobe-service/lookbooks/\(lookbookId)/add-outfit/\(outfitId)",
            method: "POST",
            completion: completion
        )
    }
    
    func removeOutfit(from lookbookId: Int, outfitId: Int, completion: @escaping (Result<Void, Error>) -> Void) {
        api.requestVoid(
            path: "/wardrobe-service/lookbooks/\(lookbookId)/outfit=\(outfitId)",
            method: "DELETE",
            completion: completion
        )
    }


    func updateLookbook(lookbookId: Int, name: String, description: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let payload = ["name": name, "description": description]
        guard let body = try? JSONEncoder().encode(payload) else {
            return completion(.failure(NSError(domain: "Encoding error", code: 500)))
        }

        api.requestVoid(
            path: "/wardrobe-service/lookbooks/\(lookbookId)/update",
            method: "PATCH",
            body: body,
            completion: completion
        )
    }

    func deleteLookbook(lookbookId: Int, completion: @escaping (Result<Void, Error>) -> Void) {
        api.requestVoid(
            path: "/wardrobe-service/lookbooks/\(lookbookId)/delete",
            method: "DELETE",
            completion: completion
        )
    }
}
