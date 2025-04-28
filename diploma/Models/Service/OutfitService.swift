//
//  OutfitService.swift
//  diploma
//
//  Created by Olga on 23.04.2025.
//

import Foundation
import Foundation
import UIKit

class OutfitService {
    static let shared = OutfitService()

    func createOutfit(request: CreateOutfitRequest, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let url = URL(string: "https://gate-acidnaya.amvera.io/api/v1/wardrobe-service/outfits/create") else {
            print("Неверный URL")
            completion(.failure(NSError(domain: "Bad URL", code: 400)))
            return
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")

        if let token = KeychainHelper.get(forKey: "accessToken") {
            urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            print("Токен: Bearer \(token)")
        } else {
            print("Токен не найден")
        }

        do {
            let jsonData = try JSONEncoder().encode(request)
            urlRequest.httpBody = jsonData

            if let jsonString = String(data: jsonData, encoding: .utf8) {
                print("Тело запроса:\n\(jsonString)")
            }
        } catch {
            print("Ошибка кодирования JSON: \(error)")
            completion(.failure(error))
            return
        }

        URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            if let error = error {
                print("Ошибка при отправке запроса: \(error)")
                completion(.failure(error))
                return
            }

            if let httpResponse = response as? HTTPURLResponse {
                print("Код ответа: \(httpResponse.statusCode)")
            }

            if let data = data,
               let raw = String(data: data, encoding: .utf8) {
                print("Ответ сервера:\n\(raw)")
            }

            if let httpResponse = response as? HTTPURLResponse,
               (200..<300).contains(httpResponse.statusCode) {
                print("Аутфит успешно создан на сервере")
                completion(.success(()))
            } else {
                print("Ошибка сервера")
                completion(.failure(NSError(domain: "Server error", code: 500)))
            }
        }.resume()
    }
    
    func fetchOutfits(for wardrobeId: Int, completion: @escaping (Result<[OutfitResponse], Error>) -> Void) {
            guard let url = URL(string: "https://gate-acidnaya.amvera.io/api/v1/wardrobe-service/outfits/wardrobe=\(wardrobeId)/all") else {
                print("Невалидный URL")
                completion(.failure(NSError(domain: "Invalid URL", code: 400)))
                return
            }

            var request = URLRequest(url: url)
            request.httpMethod = "GET"

            if let token = KeychainHelper.get(forKey: "accessToken") {
                request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
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

                        let fetchedOutfits = try decoder.decode([OutfitResponse].self, from: data)
                        completion(.success(fetchedOutfits))
                    } catch {
                        print("Ошибка декодирования: \(error)")
                        if let raw = String(data: data, encoding: .utf8) {
                            print("Ответ сервера:\n\(raw)")
                        }
                        completion(.failure(error))
                    }
                }
            }.resume()
        }
}
