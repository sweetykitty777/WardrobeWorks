//
//  AuthServiceRegister.swift
//  diploma
//
//  Created by Olga on 09.05.2025.
//

import Foundation

extension AuthService {
    func register(email: String, password: String, username: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let body = [
            "email": email,
            "password": password,
            "username": username
        ]
        guard let data = try? JSONSerialization.data(withJSONObject: body) else {
            completion(.failure(NSError(domain: "Ошибка кодирования", code: 1002)))
            return
        }

        ApiClient.shared.requestVoid(
            path: "/auth/register",
            method: "POST",
            body: data,
            completion: completion
        )
    }

    func sendForgotPassword(email: String, completion: @escaping (Result<Void, Error>) -> Void) {
        ApiClient.shared.unauthorizedRequestVoid(
            path: "/auth/forgot-password",
            method: "POST",
            query: ["email": email],
            completion: completion
        )
    }
    
    func resetPassword(token: String, newPassword: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let query = [
            "token": token,
            "newPassword": newPassword
        ]

        ApiClient.shared.unauthorizedRequestVoid(
            path: "/auth/reset-password",
            method: "POST",
            query: query,
            completion: completion
        )
    }
}
