//  WardrobeServiceAccess.swift
//  diploma
//
//  Created by Olga on 04.05.2025.
//

import Foundation

extension WardrobeService {

    func fetchAccessList(completion: @escaping (Result<[SharedAccess], Error>) -> Void) {
        api.request(
            path: "/wardrobe-service/access/all",
            method: "GET",
            decodeTo: [SharedAccess].self,
            completion: completion
        )
    }

    func grantAccess(wardrobeId: Int, grantedToUserId: Int, accessType: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let payload: [String: Any] = [
            "wardrobeId": wardrobeId,
            "grantedToUserId": grantedToUserId,
            "accessType": accessType
        ]

        guard let body = try? JSONSerialization.data(withJSONObject: payload, options: []) else {
            return completion(.failure(NSError(domain: "Encoding error", code: 500)))
        }

        api.requestVoid(
            path: "/wardrobe-service/access/grant",
            method: "POST",
            body: body,
            completion: completion
        )
    }

    func revokeAccess(accessId: Int, completion: @escaping (Result<Void, Error>) -> Void) {
        api.requestVoid(
            path: "/wardrobe-service/access/\(accessId)/revoke",
            method: "POST",
            completion: completion
        )
    }
}
