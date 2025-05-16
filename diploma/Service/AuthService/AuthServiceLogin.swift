//
//  AuthServiceLogin.swift
//  diploma
//
//  Created by Olga on 09.05.2025.
//

import Foundation

extension AuthService {
    func login(email: String, password: String, completion: @escaping (Result<LoginResponse, Error>) -> Void) {
        let body = ["email": email, "password": password]
        guard let data = try? JSONSerialization.data(withJSONObject: body) else {
            completion(.failure(NSError(domain: "Ошибка кодирования", code: 1001)))
            return
        }

        ApiClient.shared.request(
            path: "/auth/login",
            method: "POST",
            body: data,
            decodeTo: LoginResponse.self,
            completion: completion
        )
    }
}
