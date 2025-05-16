//
//  WardrobeService.swift
//  diploma
//
//  Created by Olga on 20.04.2025.
//

import Foundation


class WardrobeService {
    static let shared = WardrobeService()
    
    func createWardrobe(request: CreateWardrobeRequest, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let url = URL(string: "https://gate-acidnaya.amvera.io/api/v1/wardrobe-service/wardrobes/create") else {
            completion(.failure(NSError(domain: "Invalid URL", code: 400)))
            return
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")

        if let token = KeychainHelper.get(forKey: "accessToken") {
            urlRequest.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            print("🪪 Токен: Bearer \(token)")
        }

        do {
            let bodyData = try JSONEncoder().encode(request)
            urlRequest.httpBody = bodyData
            print("📤 Тело запроса: \(String(data: bodyData, encoding: .utf8) ?? "Ошибка сериализации")")
        } catch {
            print("❌ Ошибка сериализации тела: \(error)")
            completion(.failure(error))
            return
        }

        URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            if let error = error {
                print("❌ Ошибка сети: \(error)")
                completion(.failure(error))
                return
            }

            if let httpResponse = response as? HTTPURLResponse {
                print("📬 Ответ сервера: \(httpResponse.statusCode)")
            }

            if let data = data,
               let json = try? JSONSerialization.jsonObject(with: data, options: []),
               let pretty = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted),
               let string = String(data: pretty, encoding: .utf8) {
                print("📨 Ответ JSON:\n\(string)")
            }

            if let httpResponse = response as? HTTPURLResponse,
               (200..<300).contains(httpResponse.statusCode) {
                print("✅ Гардероб успешно создан")
                completion(.success(()))
            } else {
                print("❌ Ошибка создания гардероба")
                completion(.failure(NSError(domain: "Bad response", code: 400)))
            }
        }.resume()
    }
    
    func fetchWardrobes(completion: @escaping (Result<[UsersWardrobe], Error>) -> Void) {
        print("ultrameow")
        guard let url = URL(string: "https://gate-acidnaya.amvera.io/api/v1/wardrobe-service/wardrobes/all") else {
            completion(.failure(NSError(domain: "Invalid URL", code: 400)))
            return
        }

        print("meow")
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        if let token = KeychainHelper.get(forKey: "accessToken") {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            print("🪪 Токен: \(token)")
        }
        

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Ошибка: \(error)")
                completion(.failure(error))
                return
            }

            if let httpResponse = response as? HTTPURLResponse {
                print("📬 Код ответа: \(httpResponse.statusCode)")
            }

            guard let data = data else {
                print("❌ Нет данных от сервера")
                completion(.failure(NSError(domain: "No data", code: 500)))
                return
            }
            
            
            print("🧪 Дамп данных из сервера: \(data.count) байт")

            let rawString = String(data: data, encoding: .utf8) ?? "— не строка —"
            print("📦 Raw response:\n\(rawString)")

            if let json = try? JSONSerialization.jsonObject(with: data, options: []),
               let pretty = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted),
               let string = String(data: pretty, encoding: .utf8) {
                print("📨 Ответ JSON:\n\(string)")
            } else {
                print("⚠️ JSON не удалось распарсить")
            }

            print(data)
            do {
                let decoded = try JSONDecoder().decode([UsersWardrobe].self, from: data)
                print("📥 Гардеробы загружены: \(decoded.count)")
                completion(.success(decoded))
            } catch {
                print("❌ Ошибка декодирования гардеробов: \(error)")
                completion(.failure(error))
            }
        }.resume()
    }

    // 🔎 Получить гардероб по ID
    func getWardrobe(by id: Int, completion: @escaping (Result<UsersWardrobe, Error>) -> Void) {
        guard let url = URL(string: "https://gate-acidnaya.amvera.io/api/v1/wardrobe-service/wardrobes/\(id)") else {
            completion(.failure(NSError(domain: "Invalid URL", code: 400)))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        if let token = KeychainHelper.get(forKey: "accessToken") {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "No data", code: 500)))
                return
            }

            do {
                let wardrobe = try JSONDecoder().decode(UsersWardrobe.self, from: data)
                completion(.success(wardrobe))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }

    // 👥 Получить гардеробы другого пользователя
    func getWardrobes(of userId: Int, completion: @escaping (Result<[UsersWardrobe], Error>) -> Void) {
        guard let url = URL(string: "https://gate-acidnaya.amvera.io/api/v1/wardrobe-service/wardrobes/\(userId)/all") else {
            completion(.failure(NSError(domain: "Invalid URL", code: 400)))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        if let token = KeychainHelper.get(forKey: "accessToken") {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "No data", code: 500)))
                return
            }

            do {
                let decoded = try JSONDecoder().decode([UsersWardrobe].self, from: data)
                completion(.success(decoded))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }

    // 🗑️ Удалить (скрыть) гардероб
    func removeWardrobe(id: Int, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let url = URL(string: "https://gate-acidnaya.amvera.io/api/v1/wardrobe-service/wardrobes/\(id)/remove") else {
            completion(.failure(NSError(domain: "Invalid URL", code: 400)))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        if let token = KeychainHelper.get(forKey: "accessToken") {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        URLSession.shared.dataTask(with: request) { _, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse, (200..<300).contains(httpResponse.statusCode) else {
                completion(.failure(NSError(domain: "Bad response", code: 500)))
                return
            }

            completion(.success(()))
        }.resume()
    }
    
    // 🔐 Получить список всех доступов
    func fetchAccessList(completion: @escaping (Result<[SharedAccess], Error>) -> Void) {
        guard let url = URL(string: "https://gate-acidnaya.amvera.io/api/v1/wardrobe-service/access/all") else {
            completion(.failure(NSError(domain: "Invalid URL", code: 400)))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        if let token = KeychainHelper.get(forKey: "accessToken") {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "No data", code: 500)))
                return
            }

            do {
                let decoded = try JSONDecoder().decode([SharedAccess].self, from: data)
                completion(.success(decoded))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }

    // ➕ Выдать доступ пользователю
    func grantAccess(wardrobeId: Int, grantedToUserId: Int, accessType: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let url = URL(string: "https://gate-acidnaya.amvera.io/api/v1/wardrobe-service/access/grant") else {
            completion(.failure(NSError(domain: "Invalid URL", code: 400)))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        if let token = KeychainHelper.get(forKey: "accessToken") {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        let body: [String: Any] = [
            "wardrobeId": wardrobeId,
            "grantedToUserId": grantedToUserId,
            "accessType": accessType
        ]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
        } catch {
            completion(.failure(error))
            return
        }

        URLSession.shared.dataTask(with: request) { _, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse, (200..<300).contains(httpResponse.statusCode) else {
                completion(.failure(NSError(domain: "Bad response", code: 500)))
                return
            }

            completion(.success(()))
        }.resume()
    }

    // ❌ Отозвать доступ
    func revokeAccess(accessId: Int, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let url = URL(string: "https://gate-acidnaya.amvera.io/api/v1/wardrobe-service/access/\(accessId)/revoke") else {
            completion(.failure(NSError(domain: "Invalid URL", code: 400)))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        if let token = KeychainHelper.get(forKey: "accessToken") {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        URLSession.shared.dataTask(with: request) { _, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse, (200..<300).contains(httpResponse.statusCode) else {
                completion(.failure(NSError(domain: "Bad response", code: 500)))
                return
            }

            completion(.success(()))
        }.resume()
    }

    // 👕 Создать вещь в гардеробе
    func createClothingItem(wardrobeId: Int, request: CreateClothingItemRequest, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let url = URL(string: "https://gate-acidnaya.amvera.io/api/v1/wardrobe-service/clothes/\(wardrobeId)/create") else {
            completion(.failure(NSError(domain: "Invalid URL", code: 400)))
            return
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")

        if let token = KeychainHelper.get(forKey: "accessToken") {
            urlRequest.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        do {
            let bodyData = try JSONEncoder().encode(request)
            urlRequest.httpBody = bodyData
            print("📤 Тело запроса: \(String(data: bodyData, encoding: .utf8) ?? "Ошибка сериализации")")
        } catch {
            print("❌ Ошибка сериализации тела: \(error)")
            completion(.failure(error))
            return
        }

        URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            if let error = error {
                print("❌ Ошибка сети: \(error)")
                completion(.failure(error))
                return
            }

            if let httpResponse = response as? HTTPURLResponse {
                print("📬 Ответ сервера: \(httpResponse.statusCode)")
            }

            if let data = data,
               let json = try? JSONSerialization.jsonObject(with: data, options: []),
               let pretty = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted),
               let string = String(data: pretty, encoding: .utf8) {
                print("📨 Ответ JSON:\n\(string)")
            }

            if let httpResponse = response as? HTTPURLResponse,
               (200..<300).contains(httpResponse.statusCode) {
                print("✅ Вещь успешно создана")
                completion(.success(()))
            } else {
                print("❌ Ошибка создания вещи")
                completion(.failure(NSError(domain: "Bad response", code: 400)))
            }
        }.resume()
    }

}
