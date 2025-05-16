//
//  SocialServiceFollow.swift
//  diploma
//
//  Created by Olga on 04.05.2025.
//

import Foundation

extension SocialService {

    func isFollowing(userId: Int, completion: @escaping (Bool) -> Void) {
        api.request(
            path: "/social-service/follow/is-following/\(userId)",
            method: "GET",
            decodeTo: Bool.self
        ) { result in
            DispatchQueue.main.async {
                completion((try? result.get()) ?? false)
            }
        }
    }

    func follow(userId: Int, completion: @escaping (Bool) -> Void) {
        changeFollowState(userId: userId, method: "POST", completion: completion)
    }

    func unfollow(userId: Int, completion: @escaping (Bool) -> Void) {
        changeFollowState(userId: userId, method: "DELETE", completion: completion)
    }

    private func changeFollowState(userId: Int, method: String, completion: @escaping (Bool) -> Void) {
        api.requestVoid(
            path: "/social-service/follow/\(userId)",
            method: method
        ) { result in
            DispatchQueue.main.async {
                completion((try? result.get()) != nil)
            }
        }
    }
}
