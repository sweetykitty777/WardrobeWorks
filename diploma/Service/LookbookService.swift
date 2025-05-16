import Foundation
/*
class LookbookService {
    static let shared = LookbookService()

    private init() {}

    func createLookbook(wardrobeId: Int, name: String, description: String = "", completion: @escaping (Result<Void, Error>) -> Void) {
        guard let url = URL(string: "https://gate-acidnaya.amvera.io/api/v1/wardrobe-service/lookbooks/\(wardrobeId)/create") else {
            print("Невалидный URL для создания лукбука")
            completion(.failure(NSError(domain: "Invalid URL", code: 400)))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        if let token = KeychainHelper.get(forKey: "accessToken") {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            print("Токен добавлен в заголовок авторизации")
        } else {
            print("Токен не найден")
        }

        let body: [String: Any] = [
            "name": name,
            "description": description
        ]

        do {
            let jsonData = try JSONSerialization.data(withJSONObject: body, options: .prettyPrinted)
            request.httpBody = jsonData
            print("Тело запроса:")
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                print(jsonString)
            }
        } catch {
            print("Ошибка сериализации тела запроса: \(error)")
            completion(.failure(error))
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Ошибка сети при отправке запроса: \(error)")
                    completion(.failure(error))
                    return
                }

                if let httpResponse = response as? HTTPURLResponse {
                    print("Код ответа: \(httpResponse.statusCode)")
                }

                if let data = data {
                    let rawResponse = String(data: data, encoding: .utf8) ?? "— нет данных —"
                    print("Ответ от сервера:\n\(rawResponse)")
                }

                if let httpResponse = response as? HTTPURLResponse, (200..<300).contains(httpResponse.statusCode) {
                    print("Лукбук успешно создан")
                    completion(.success(()))
                } else {
                    print("Сервер вернул ошибку")
                    completion(.failure(NSError(domain: "Server error", code: 500)))
                }
            }
        }.resume()
    }

    func fetchLookbooks(for wardrobeId: Int, completion: @escaping (Result<[LookbookResponse], Error>) -> Void) {
        guard let url = URL(string: "https://gate-acidnaya.amvera.io/api/v1/wardrobe-service/lookbooks/wardrobe=\(wardrobeId)/all") else {
            print("Невалидный URL для получения лукбуков")
            completion(.failure(NSError(domain: "Invalid URL", code: 400)))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        if let token = KeychainHelper.get(forKey: "accessToken") {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            print("Добавлен токен авторизации")
        } else {
            print("Токен не найден")
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Ошибка запроса: \(error)")
                    completion(.failure(error))
                    return
                }

                guard let data = data else {
                    print("Пустой ответ от сервера")
                    completion(.failure(NSError(domain: "No data", code: 500)))
                    return
                }

                print("Сырые данные:\n\(String(data: data, encoding: .utf8) ?? "не удалось декодировать")")

                do {
                    let decoder = JSONDecoder()
                    let formatter = ISO8601DateFormatter()
                    formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

                    decoder.dateDecodingStrategy = .custom { decoder in
                        let container = try decoder.singleValueContainer()
                        let dateStr = try container.decode(String.self)

                        if let date = formatter.date(from: dateStr) {
                            return date
                        } else {
                            throw DecodingError.dataCorruptedError(
                                in: container,
                                debugDescription: "Invalid ISO8601 date: \(dateStr)"
                            )
                        }
                    }

                    let lookbooks = try decoder.decode([LookbookResponse].self, from: data)
                    print("Получено \(lookbooks.count) лукбуков")
                    completion(.success(lookbooks))
                } catch {
                    print("Ошибка декодирования: \(error)")
                    completion(.failure(error))
                }
            }
        }.resume()
    }
    
    
    func addOutfit(to lookbookId: Int, outfitId: Int, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let url = URL(string: "https://gate-acidnaya.amvera.io/api/v1/wardrobe-service/lookbooks/\(lookbookId)/add-outfit/\(outfitId)") else {
            print("Невалидный URL для добавления аутфита")
            completion(.failure(NSError(domain: "Invalid URL", code: 400)))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        if let token = KeychainHelper.get(forKey: "accessToken") {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            print("Добавлен токен авторизации")
        } else {
            print("Токен не найден")
        }

        print("Отправляем запрос на добавление аутфита \(outfitId) в лукбук \(lookbookId)")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Ошибка сети при добавлении аутфита: \(error)")
                    completion(.failure(error))
                    return
                }

                if let httpResponse = response as? HTTPURLResponse {
                    print("Код ответа: \(httpResponse.statusCode)")
                }

                if let data = data {
                    let rawResponse = String(data: data, encoding: .utf8) ?? "— нет данных —"
                    print("Ответ от сервера:\n\(rawResponse)")
                }

                if let httpResponse = response as? HTTPURLResponse, (200..<300).contains(httpResponse.statusCode) {
                    print("Аутфит успешно добавлен в лукбук")
                    completion(.success(()))
                } else {
                    print("Сервер вернул ошибку при добавлении аутфита")
                    completion(.failure(NSError(domain: "Server error", code: 500)))
                }
            }
        }.resume()
    }
    
    func updateLookbook(lookbookId: Int, name: String, description: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let url = URL(string: "https://gate-acidnaya.amvera.io/api/v1/wardrobe-service/lookbooks/\(lookbookId)/update") else {
            completion(.failure(NSError(domain: "Invalid URL", code: 400)))
            return
        }

        var req = URLRequest(url: url)
        req.httpMethod = "PATCH"
        req.addValue("application/json", forHTTPHeaderField: "Content-Type")
        if let token = KeychainHelper.get(forKey: "accessToken") {
            req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        let body: [String: String] = ["name": name, "description": description]
        req.httpBody = try? JSONEncoder().encode(body)

        URLSession.shared.dataTask(with: req) { _, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                } else if let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) {
                    completion(.success(()))
                } else {
                    completion(.failure(NSError(domain: "Server error", code: 500)))
                }
            }
        }.resume()
    }

    func deleteLookbook(lookbookId: Int, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let url = URL(string: "https://gate-acidnaya.amvera.io/api/v1/wardrobe-service/lookbooks/\(lookbookId)/delete") else {
            completion(.failure(NSError(domain: "Invalid URL", code: 400)))
            return
        }

        var req = URLRequest(url: url)
        req.httpMethod = "DELETE"
        if let token = KeychainHelper.get(forKey: "accessToken") {
            req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        URLSession.shared.dataTask(with: req) { _, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                } else if let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) {
                    completion(.success(()))
                } else {
                    completion(.failure(NSError(domain: "Server error", code: 500)))
                }
            }
        }.resume()
    }

}
*/
