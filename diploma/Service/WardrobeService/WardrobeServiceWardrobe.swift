//  WardrobeServiceWardrobe.swift
//  diploma
//
//  Created by Olga on 04.05.2025.

import Foundation

extension WardrobeService {

    func createWardrobe(request payload: CreateWardrobeRequest, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let body = try? JSONEncoder().encode(payload) else {
            return completion(.failure(NSError(domain: "Encoding error", code: 500)))
        }

        api.requestVoid(
            path: "/wardrobe-service/wardrobes/create",
            method: "POST",
            body: body,
            completion: completion
        )
    }

    func getWardrobe(by id: Int, completion: @escaping (Result<UsersWardrobe, Error>) -> Void) {
        api.request(
            path: "/wardrobe-service/wardrobes/\(id)",
            method: "GET",
            decodeTo: UsersWardrobe.self,
            completion: completion
        )
    }


    func fetchWardrobes(completion: @escaping (Result<[UsersWardrobe], Error>) -> Void) {
        api.request(
            path: "/wardrobe-service/wardrobes/all",
            method: "GET",
            decodeTo: [UsersWardrobe].self
        ) { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }
    }


    func getWardrobes(of userId: Int, completion: @escaping (Result<[UsersWardrobe], Error>) -> Void) {
        api.request(
            path: "/wardrobe-service/wardrobes/\(userId)/all",
            method: "GET",
            decodeTo: [UsersWardrobe].self,
            completion: completion
        )
    }

    func changeWardrobePrivacy(id: Int, isPrivate: Bool, completion: @escaping (Result<Void, Error>) -> Void) {
        let query = "?isPrivate=\(isPrivate)"
        api.requestVoid(
            path: "/wardrobe-service/wardrobes/\(id)/change-privacy\(query)",
            method: "PATCH",
            completion: completion
        )
    }

    func removeWardrobe(id: Int, completion: @escaping (Result<Void, Error>) -> Void) {
        api.requestVoid(
            path: "/wardrobe-service/wardrobes/\(id)/remove",
            method: "PATCH",
            completion: completion
        )
    }
}
