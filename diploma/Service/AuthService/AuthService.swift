//
//  AuthService.swift
//  diploma
//

import Foundation

final class AuthService {
    static let shared = AuthService()
    private let api = ApiClient.shared

    private init() {}

  /*  func register(email: String, password: String, username: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let payload = [
            "email": email,
            "password": password,
            "username": username
        ]
        guard let body = try? JSONSerialization.data(withJSONObject: payload) else {
            return completion(.failure(NSError(domain: "Encoding error", code: 500)))
        }

        api.requestVoid(
            path: "/auth/register",
            method: "POST",
            body: body,
            completion: completion
        )
    }

    func login(email: String, password: String, completion: @escaping (Result<LoginResponse, Error>) -> Void) {
        let payload = [
            "email": email,
            "password": password
        ]
        guard let body = try? JSONSerialization.data(withJSONObject: payload) else {
            return completion(.failure(NSError(domain: "Encoding error", code: 500)))
        }

        api.request(
            path: "/auth/login",
            method: "POST",
            body: body,
            decodeTo: LoginResponse.self,
            completion: completion
        )
    }

    func fetchCurrentUser(completion: @escaping (Result<UserProfile, Error>) -> Void) {
        api.request(
            path: "/social-service/users/self",
            method: "GET",
            decodeTo: UserProfile.self,
            completion: completion
        )
    }

    func setUsername(_ newUsername: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let payload = ["username": newUsername]
        guard let body = try? JSONEncoder().encode(payload) else {
            return completion(.failure(NSError(domain: "Encoding error", code: 500)))
        }

        api.requestVoid(
            path: "/social-service/users/create",
            method: "POST",
            body: body,
            completion: completion
        )
    }

    func logout() {
        KeychainHelper.delete(forKey: "accessToken")
        TokenManager.shared.stopMonitoring()
    }*/
}
