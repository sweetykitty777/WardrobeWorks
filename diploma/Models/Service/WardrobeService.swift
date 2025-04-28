//
//  WardrobeService.swift
//  diploma
//
//  Created by Olga on 20.04.2025.
//

import Foundation


class WardrobeService {
    static let shared = WardrobeService()
    
    func changeWardrobePrivacy(id: Int, isPrivate: Bool, completion: @escaping (Result<Void, Error>) -> Void) {
        guard var components = URLComponents(string: "https://gate-acidnaya.amvera.io/api/v1/wardrobe-service/wardrobes/\(id)/change-privacy") else {
            completion(.failure(NSError(domain: "Invalid URL", code: 400)))
            return
        }
        components.queryItems = [ URLQueryItem(name: "isPrivate", value: isPrivate ? "true" : "false") ]
        guard let url = components.url else {
            completion(.failure(NSError(domain: "Invalid URL components", code: 400)))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue("*/*", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let token = KeychainHelper.get(forKey: "accessToken") {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        print("PATCH приватности: \(url.absoluteString)")

        URLSession.shared.dataTask(with: request) { _, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Ошибка при смене приватности: \(error)")
                    completion(.failure(error))
                    return
                }
                if let http = response as? HTTPURLResponse {
                    print("Код ответа приватности: \(http.statusCode)")
                    if (200..<300).contains(http.statusCode) {
                        completion(.success(()))
                    } else {
                        completion(.failure(NSError(domain: "Server", code: http.statusCode)))
                    }
                } else {
                    completion(.failure(NSError(domain: "No HTTP response", code: 500)))
                }
            }
        }.resume()
    }
    
    func updateClothingItem(id: Int, request: UpdateClothingItemRequest, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let url = URL(string: "https://gate-acidnaya.amvera.io/api/v1/wardrobe-service/clothes/\(id)/update-features") else {
            completion(.failure(NSError(domain: "Invalid URL", code: 400)))
            return
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "PATCH"
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")

        if let token = KeychainHelper.get(forKey: "accessToken") {
            urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        do {
            let data = try JSONEncoder().encode(request)
            urlRequest.httpBody = data
        } catch {
            completion(.failure(error))
            return
        }

        URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            if let error = error {
                print("Ошибка сети:", error.localizedDescription)
                completion(.failure(error))
                return
            }

            if let httpResponse = response as? HTTPURLResponse {
                print("Код ответа: \(httpResponse.statusCode)")
            }

            if let data = data {
                let raw = String(data: data, encoding: .utf8) ?? "— не строка —"
                print("Ответ сервера:\n\(raw)")
            }

            if let httpResponse = response as? HTTPURLResponse,
               (200..<300).contains(httpResponse.statusCode) {
                completion(.success(()))
            } else {
                let errorMessage = NSError(domain: "Bad response", code: 500, userInfo: [
                    NSLocalizedDescriptionKey: "Некорректный ответ от сервера"
                ])
                completion(.failure(errorMessage))
            }
        }.resume()


    }

    
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
            print("Токен: Bearer \(token)")
        }

        do {
            let bodyData = try JSONEncoder().encode(request)
            urlRequest.httpBody = bodyData
            print("Тело запроса: \(String(data: bodyData, encoding: .utf8) ?? "Ошибка сериализации")")
        } catch {
            print("Ошибка сериализации тела: \(error)")
            completion(.failure(error))
            return
        }

        URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            if let error = error {
                print("Ошибка сети: \(error)")
                completion(.failure(error))
                return
            }

            if let httpResponse = response as? HTTPURLResponse {
                print("Ответ сервера: \(httpResponse.statusCode)")
            }

            if let data = data,
               let json = try? JSONSerialization.jsonObject(with: data, options: []),
               let pretty = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted),
               let string = String(data: pretty, encoding: .utf8) {
                print("Ответ JSON:\n\(string)")
            }

            if let httpResponse = response as? HTTPURLResponse,
               (200..<300).contains(httpResponse.statusCode) {
                print("Гардероб успешно создан")
                completion(.success(()))
            } else {
                print("Ошибка создания гардероба")
                completion(.failure(NSError(domain: "Bad response", code: 400)))
            }
        }.resume()
    }
    
    func fetchWardrobes(completion: @escaping (Result<[UsersWardrobe], Error>) -> Void) {
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
                print("Ошибка: \(error)")
                completion(.failure(error))
                return
            }

            if let httpResponse = response as? HTTPURLResponse {
                print("Код ответа: \(httpResponse.statusCode)")
            }

            guard let data = data else {
                print("Нет данных от сервера")
                completion(.failure(NSError(domain: "No data", code: 500)))
                return
            }
            
            
            print("Дамп данных из сервера: \(data.count) байт")

            let rawString = String(data: data, encoding: .utf8) ?? "— не строка —"
            print("Raw response:\n\(rawString)")

            if let json = try? JSONSerialization.jsonObject(with: data, options: []),
               let pretty = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted),
               let string = String(data: pretty, encoding: .utf8) {
                print("Ответ JSON:\n\(string)")
            } else {
                print("JSON не удалось распарсить")
            }

            print(data)
            do {
                let decoded = try JSONDecoder().decode([UsersWardrobe].self, from: data)
                print("Гардеробы загружены: \(decoded.count)")
                completion(.success(decoded))
            } catch {
                print("Ошибка декодирования гардеробов: \(error)")
                completion(.failure(error))
            }
        }.resume()
    }
    
    func deleteClothingItem(id: Int, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "https://gate-acidnaya.amvera.io/api/v1/wardrobe-service/clothes/\(id)") else {
            completion(false)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        if let token = KeychainHelper.get(forKey: "accessToken") {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        URLSession.shared.dataTask(with: request) { _, response, error in
            if let httpResponse = response as? HTTPURLResponse,
               (200..<300).contains(httpResponse.statusCode) {
                completion(true)
            } else {
                completion(false)
            }
        }.resume()
    }


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

    func grantAccess(wardrobeId: Int, grantedToUserId: Int, accessType: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let url = URL(string: "https://gate-acidnaya.amvera.io/api/v1/wardrobe-service/access/grant") else {
            print("Невалидный URL для grantAccess")
            completion(.failure(NSError(domain: "Invalid URL", code: 400)))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        if let token = KeychainHelper.get(forKey: "accessToken") {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            print("Авторизация добавлена")
        }

        let body: [String: Any] = [
            "wardrobeId": wardrobeId,
            "grantedToUserId": grantedToUserId,
            "accessType": accessType
        ]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
            if let jsonString = String(data: request.httpBody ?? Data(), encoding: .utf8) {
                print("Тело запроса на выдачу доступа:\n\(jsonString)")
            }
        } catch {
            print("Ошибка сериализации тела запроса:", error)
            completion(.failure(error))
            return
        }

        print("Отправляем запрос grantAccess: \(url.absoluteString)")

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Ошибка сети при выдаче доступа: \(error)")
                    completion(.failure(error))
                    return
                }

                if let httpResponse = response as? HTTPURLResponse {
                    print("Код ответа grantAccess: \(httpResponse.statusCode)")
                }

                if let data = data, let responseString = String(data: data, encoding: .utf8) {
                    print("Ответ сервера grantAccess:\n\(responseString)")
                }

                if let httpResponse = response as? HTTPURLResponse, (200..<300).contains(httpResponse.statusCode) {
                    print("Доступ успешно выдан")
                    completion(.success(()))
                } else {
                    print("Ошибка при выдаче доступа")
                    completion(.failure(NSError(domain: "Bad response", code: 500)))
                }
            }
        }.resume()
    }

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
            print("Тело запроса: \(String(data: bodyData, encoding: .utf8) ?? "Ошибка сериализации")")
        } catch {
            print("Ошибка сериализации тела: \(error)")
            completion(.failure(error))
            return
        }

        URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            if let error = error {
                print("Ошибка сети: \(error)")
                completion(.failure(error))
                return
            }

            if let httpResponse = response as? HTTPURLResponse {
                print("Ответ сервера: \(httpResponse.statusCode)")
            }

            if let data = data,
               let json = try? JSONSerialization.jsonObject(with: data, options: []),
               let pretty = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted),
               let string = String(data: pretty, encoding: .utf8) {
                print("Ответ JSON:\n\(string)")
            }

            if let httpResponse = response as? HTTPURLResponse,
               (200..<300).contains(httpResponse.statusCode) {
                print("Вещь успешно создана")
                completion(.success(()))
            } else {
                print("Ошибка создания вещи")
                completion(.failure(NSError(domain: "Bad response", code: 400)))
            }
        }.resume()
    }
    
    // 🧥 Получить список вещей по wardrobeId
    func fetchClothes(for wardrobeId: Int, completion: @escaping (Result<[ClothItem], Error>) -> Void) {
        guard let url = URL(string: "https://gate-acidnaya.amvera.io/api/v1/wardrobe-service/clothes/\(wardrobeId)/all") else {
            completion(.failure(NSError(domain: "Invalid URL", code: 400)))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        if let token = KeychainHelper.get(forKey: "accessToken") {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "No data", code: 500)))
                return
            }

            do {
                let decoded = try JSONDecoder().decode([ClothItem].self, from: data)
                completion(.success(decoded))
            } catch {
                print("Ошибка декодирования одежды: \(error)")
                completion(.failure(error))
            }
        }.resume()
    }

    
    func fetchClothingTypes(completion: @escaping (Result<[ClothingContentItem], Error>) -> Void) {
        fetchContent(from: "/content/types", completion: completion)
    }

    func fetchSeasons(completion: @escaping (Result<[ClothingContentItem], Error>) -> Void) {
        fetchContent(from: "/content/seasons", completion: completion)
    }
    
    func fetchBrands(completion: @escaping (Result<[ClothingContentItem], Error>) -> Void) {
        fetchContent(from: "/content/brands", completion: completion)
    }

    private func fetchContent(from endpoint: String, completion: @escaping (Result<[ClothingContentItem], Error>) -> Void) {
        guard let url = URL(string: "https://gate-acidnaya.amvera.io/api/v1/wardrobe-service\(endpoint)") else {
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
                let decoded = try JSONDecoder().decode([ClothingContentItem].self, from: data)
                completion(.success(decoded))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    func fetchColors(completion: @escaping (Result<[ClothingColor], Error>) -> Void) {
        guard let url = URL(string: "https://gate-acidnaya.amvera.io/api/v1/wardrobe-service/content/colours") else {
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
                let decoded = try JSONDecoder().decode([ClothingColor].self, from: data)
                completion(.success(decoded))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }



}
