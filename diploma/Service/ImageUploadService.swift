//
//  ImageUploadService.swift
//  diploma
//
//  Created by Olga on 22.04.2025.
//

import UIKit
import Foundation
/*
final class ImageUploadService {
    static let shared = ImageUploadService()

    private init() {}

    func uploadImage(_ image: UIImage, completion: @escaping (Result<String, Error>) -> Void) {
        guard let url = URL(string: "https://gate-acidnaya.amvera.io/api/v1/wardrobe-service/images/upload") else {
            completion(.failure(NSError(domain: "Invalid URL", code: 400)))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        if let token = KeychainHelper.get(forKey: "accessToken") {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            completion(.failure(NSError(domain: "Invalid image data", code: 400)))
            return
        }

        var body = Data()
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"avatar.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)

        request.httpBody = body

        print("📤 Отправка изображения на: \(url.absoluteString)")
        print("📸 Размер файла: \(imageData.count) байт")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Ошибка загрузки изображения: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }

            guard let data = data else {
                print("⚠️ Нет данных в ответе от сервера")
                completion(.failure(NSError(domain: "No data", code: 500)))
                return
            }

            if let httpResponse = response as? HTTPURLResponse {
                print("📬 Код ответа от сервера: \(httpResponse.statusCode)")
            }

            if let rawResponse = String(data: data, encoding: .utf8) {
                print("📦 Ответ сервера (сырое содержимое): \(rawResponse)")
            }

            if var path = String(data: data, encoding: .utf8)?
                .trimmingCharacters(in: CharacterSet(charactersIn: "\" \n\r")) {
                print("📦 Путь из ответа: \(path)")
                let fullUrl = "https://gate-acidnaya.amvera.io/images/" + path
                print("✅ Загружено. Публичный URL: \(fullUrl)")
                completion(.success(fullUrl))
            } else {
                print("❌ Невозможно извлечь путь из ответа")
                completion(.failure(NSError(domain: "Invalid response format", code: 500)))
            }
        }.resume()
    }


    
    func uploadPNGImage(_ image: UIImage, completion: @escaping (Result<String, Error>) -> Void) {
        guard let url = URL(string: "https://gate-acidnaya.amvera.io/api/v1/wardrobe-service/images/upload") else {
            completion(.failure(NSError(domain: "Invalid URL", code: 400)))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        if let token = KeychainHelper.get(forKey: "accessToken") {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        guard let imageData = image.pngData() else {
            completion(.failure(NSError(domain: "Invalid image data", code: 400)))
            return
        }

        var body = Data()
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"image.png\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/png\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)

        request.httpBody = body

        print("Preparing to upload image...")
        print("URL: \(url)")
        print("HTTP Method: \(request.httpMethod ?? "Unknown")")
        print("Headers: \(request.allHTTPHeaderFields ?? [:])")
        print("Body size: \(body.count) bytes")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Upload failed with error: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }

            if let httpResponse = response as? HTTPURLResponse {
                print("HTTP Response Code: \(httpResponse.statusCode)")
                print("Response Headers: \(httpResponse.allHeaderFields)")
            }

            guard let data = data else {
                print("No data received from server")
                completion(.failure(NSError(domain: "No data", code: 500)))
                return
            }

            if let responseString = String(data: data, encoding: .utf8) {
                print("Raw response body: \(responseString)")
            } else {
                print("Could not decode response body")
            }

            guard var path = String(data: data, encoding: .utf8)?.trimmingCharacters(in: CharacterSet(charactersIn: "\" \n\r")) else {
                completion(.failure(NSError(domain: "Invalid response format", code: 500)))
                return
            }

            let fullUrl = "https://gate-acidnaya.amvera.io/images/" + path
            print("Full image URL: \(fullUrl)")
            completion(.success(fullUrl))
        }.resume()
    }

}
*/
