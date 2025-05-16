//
//  WardrobeServiceImageUpload.swift
//  diploma
//
//  Created by Olga on 04.05.2025.
//

import Foundation
import UIKit

extension WardrobeService {

    func uploadImage(_ image: UIImage, completion: @escaping (Result<String, Error>) -> Void) {
        upload(image: image, as: .jpeg, completion: completion)
    }

    func uploadPNGImage(_ image: UIImage, completion: @escaping (Result<String, Error>) -> Void) {
        upload(image: image, as: .png) { result in
            switch result {
            case .success(let url):
                print("Загружено изображение, получен URL: \(url)")
                completion(.success(url))
            case .failure(let error):
                print("Ошибка загрузки изображения:", error.localizedDescription)
                completion(.failure(error))
            }
        }
    }

    // MARK: - Private

    private enum ImageFormat {
        case jpeg
        case png

        var contentType: String {
            switch self {
            case .jpeg: return "image/jpeg"
            case .png:  return "image/png"
            }
        }

        var fileExtension: String {
            switch self {
            case .jpeg: return "jpg"
            case .png:  return "png"
            }
        }

        func imageData(from image: UIImage) -> Data? {
            switch self {
            case .jpeg:
                return image.jpegData(compressionQuality: 0.8)
            case .png:
                return image.pngData()
            }
        }
    }

    private func upload(image: UIImage, as format: ImageFormat, completion: @escaping (Result<String, Error>) -> Void) {
        guard let url = URL(string: "https://gate-acidnaya.amvera.io/api/v1/wardrobe-service/images/upload") else {
            return completion(.failure(NSError(domain: "Invalid URL", code: 400)))
        }

        guard let imageData = format.imageData(from: image) else {
            return completion(.failure(NSError(domain: "Invalid image data", code: 400)))
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        if let token = KeychainHelper.get(forKey: "accessToken") {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        var body = Data()
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"image.\(format.fileExtension)\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: \(format.contentType)\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        request.httpBody = body

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    return completion(.failure(error))
                }

                if let httpResponse = response as? HTTPURLResponse {
                    print("HTTP статус ответа сервера:", httpResponse.statusCode)

                    // Обработка больших картинок
                    if httpResponse.statusCode == 413 {
                        let error = NSError(domain: "Image too large", code: 413, userInfo: [
                            NSLocalizedDescriptionKey: "Картинка слишком большая"
                        ])
                        return completion(.failure(error))
                    }

                    if !(200...299).contains(httpResponse.statusCode) {
                        let error = NSError(domain: "Upload failed", code: httpResponse.statusCode, userInfo: [
                            NSLocalizedDescriptionKey: "Ошибка загрузки изображения (код \(httpResponse.statusCode))"
                        ])
                        return completion(.failure(error))
                    }
                }

                if let data = data {
                    print("📡 RAW серверный ответ:", String(data: data, encoding: .utf8) ?? "nil")
                }

                guard let data = data,
                      let path = String(data: data, encoding: .utf8)?
                        .trimmingCharacters(in: CharacterSet(charactersIn: "\" \n\r")) else {
                    return completion(.failure(NSError(domain: "Invalid response", code: 500)))
                }

                let fullUrl = path.hasPrefix("http")
                    ? path
                    : "https://gate-acidnaya.amvera.io/images/" + path

                print("Финальный image URL:", fullUrl)
                completion(.success(fullUrl))
            }
        }.resume()
    }

}
