//
//  ImageService.swift
//  diploma
//
//  Created by Olga on 20.04.2025.
//

import Foundation
import UIKit

class ImageService {
    static let shared = ImageService()
    
    private init() {}

    // MARK: - Сохранение изображения (Upload)
    func uploadImage(_ image: UIImage, completion: @escaping (Result<String, Error>) -> Void) {
        guard let url = URL(string: "https://gateway-service-acidnaya.amvera.io/api/v1/wardrobe-service/images/save") else {
            completion(.failure(NSError(domain: "Invalid URL", code: 400)))
            return
        }

        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            completion(.failure(NSError(domain: "Image conversion failed", code: 500)))
            return
        }

        let base64String = imageData.base64EncodedString()

        let body: [String: String] = [
            "file": base64String
        ]

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        // 🔐 Authorization
        if let token = KeychainHelper.get(forKey: "accessToken") {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        do {
            let jsonData = try JSONSerialization.data(withJSONObject: body)
            request.httpBody = jsonData
        } catch {
            completion(.failure(error))
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("❌ Ошибка отправки изображения: \(error)")
                    completion(.failure(error))
                    return
                }

                guard let data = data else {
                    completion(.failure(NSError(domain: "No data", code: 500)))
                    return
                }

                let rawString = String(data: data, encoding: .utf8) ?? "— не строка —"
                print("📦 Ответ от сервера при upload:\n\(rawString)")

                // Можно изменить под свою схему ответа
                if let path = try? JSONDecoder().decode(String.self, from: data) {
                    completion(.success(path))
                } else {
                    completion(.failure(NSError(domain: "Failed to decode path", code: 500)))
                }
            }
        }.resume()
    }

    // MARK: - Загрузка изображения (Download)
    func downloadImage(from path: String, completion: @escaping (Result<UIImage, Error>) -> Void) {
        var components = URLComponents(string: "https://gateway-service-acidnaya.amvera.io/api/v1/wardrobe-service/images/load")
        components?.queryItems = [
            URLQueryItem(name: "path", value: path)
        ]

        guard let url = components?.url else {
            completion(.failure(NSError(domain: "Invalid image path", code: 400)))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("*/*", forHTTPHeaderField: "Accept")

        // 🔐 Authorization
        if let token = KeychainHelper.get(forKey: "accessToken") {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("❌ Ошибка загрузки изображения: \(error)")
                    completion(.failure(error))
                    return
                }

                guard let data = data, let image = UIImage(data: data) else {
                    completion(.failure(NSError(domain: "Image decode failed", code: 500)))
                    return
                }

                print("✅ Изображение успешно загружено с сервера")
                completion(.success(image))
            }
        }.resume()
    }
}
