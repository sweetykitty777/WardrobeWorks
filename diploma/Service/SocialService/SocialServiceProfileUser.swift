// SocialServiceProfileUser.swift
// diploma
//
// Created by Olga on 04.05.2025.
//

import Foundation

extension SocialService {
    
    func fetchCurrentUser(completion: @escaping (Result<UserProfile, Error>) -> Void) {
        api.request(
            path: "/social-service/users/self",
            method: "GET",
            decodeTo: UserProfile.self,
            completion: completion
        )
    }

    func fetchUserById(_ userId: Int, completion: @escaping (Result<UserProfile, Error>) -> Void) {
        api.request(
            path: "/social-service/users/\(userId)",
            method: "GET",
            decodeTo: UserProfile.self,
            completion: completion
        )
    }

    func updateBio(_ bio: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let body = try? JSONEncoder().encode(["bio": bio])
        api.requestVoid(
            path: "/social-service/users/bio/update",
            method: "POST",
            body: body,
            completion: completion
        )
    }

    func updateAvatar(_ avatarUrl: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let body = try? JSONEncoder().encode(["avatar": avatarUrl])
        api.requestVoid(
            path: "/social-service/users/avatar/update",
            method: "POST",
            body: body,
            completion: completion
        )
    }

    func fetchUsername(for userId: Int, completion: @escaping (Result<String, Error>) -> Void) {
        api.request(
            path: "/social-service/users/\(userId)",
            method: "GET",
            decodeTo: UserProfile.self
        ) { result in
            switch result {
            case .success(let profile):
                completion(.success(profile.username))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func searchUsers(byUsername username: String, completion: @escaping (Result<[UserProfile], Error>) -> Void) {
        let encodedUsername = username.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? username

        api.request(
            path: "/social-service/users/find/username=\(encodedUsername)",
            method: "GET",
            decodeTo: [UserProfile].self,
            completion: completion
        )
    }
}
