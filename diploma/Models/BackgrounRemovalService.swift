//
//  BackgrounRemovalService.swift
//  diploma
//
//  Created by Olga on 04.05.2025.
//


import Foundation
import UIKit

final class BackgroundRemovalService{
    private let endpoint = URL(string: "https://gate-acidnaya.amvera.io/api/v1/image-service/remove-bg/")!

    func removeBackground(from imageData: Data, completion: @escaping (Result<UIImage, Error>) -> Void) {
        guard let token = KeychainHelper.get(forKey: "accessToken"), !token.isEmpty else {
            completion(.failure(NSError(domain: "Auth", code: 401, userInfo: [NSLocalizedDescriptionKey: "Токен не найден"])))
            return
        }

        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        var body = Data()
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"image.png\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/png\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        request.httpBody = body

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let http = response as? HTTPURLResponse,
                  (200..<300).contains(http.statusCode),
                  let data = data,
                  let image = UIImage(data: data) else {
                let code = (response as? HTTPURLResponse)?.statusCode ?? 500
                completion(.failure(NSError(domain: "Server", code: code, userInfo: [NSLocalizedDescriptionKey: "Ошибка сервера"])))
                return
            }

            completion(.success(image))
        }.resume()
    }
}
