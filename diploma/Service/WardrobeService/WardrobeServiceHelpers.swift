//
//  WardrobeServiceHelpers.swift
//  diploma
//
//  Created by Olga on 04.05.2025.
//

import Foundation

extension WardrobeService {
    
    var baseURL: String {
        "https://gate-acidnaya.amvera.io/api/v1/wardrobe-service"
    }

    // MARK: - Common request builders

    func request<T: Decodable>(
        endpoint: String,
        method: String,
        decode type: T.Type,
        dateDecoding: Bool = false,
        completion: @escaping (Result<T, Error>) -> Void
    ) {
        guard let url = URL(string: baseURL + endpoint) else {
            return completion(.failure(NSError(domain: "Invalid URL", code: 400)))
        }

        authorizedRequest(url: url, method: method) { request in
            self.perform(request, decode: type, dateDecoding: dateDecoding, completion: completion)
        }
    }

    func request(
        endpoint: String,
        method: String,
        body: [String: Any]? = nil,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        guard let url = URL(string: baseURL + endpoint) else {
            return completion(.failure(NSError(domain: "Invalid URL", code: 400)))
        }

        authorizedRequest(url: url, method: method, jsonBody: body) { request in
            self.perform(request, completion: completion)
        }
    }

    /// ✅ Новый метод: для передачи закодированного JSON `Data`
    func request(
        endpoint: String,
        method: String,
        rawBody: Data,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        guard let url = URL(string: baseURL + endpoint) else {
            return completion(.failure(NSError(domain: "Invalid URL", code: 400)))
        }

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("*/*", forHTTPHeaderField: "Accept")
        
        if let token = KeychainHelper.get(forKey: "accessToken") {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        request.httpBody = rawBody
        self.perform(request, completion: completion)
    }

    /// ✅ Перегрузка: можно передавать любой Codable как rawBody
    func request<T: Encodable>(
        endpoint: String,
        method: String,
        rawBody: T,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        do {
            let data = try JSONEncoder().encode(rawBody)
            request(endpoint: endpoint, method: method, rawBody: data, completion: completion)
        } catch {
            completion(.failure(error))
        }
    }

    // MARK: - Authorization

    func authorizedRequest(
        url: URL,
        method: String,
        jsonBody: [String: Any]? = nil,
        completion: @escaping (URLRequest) -> Void
    ) {
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("*/*", forHTTPHeaderField: "Accept")

        if let token = KeychainHelper.get(forKey: "accessToken") {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        if let body = jsonBody {
            request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        }

        completion(request)
    }

    // MARK: - Execution

    func perform<T: Decodable>(
        _ request: URLRequest,
        decode type: T.Type,
        dateDecoding: Bool = false,
        completion: @escaping (Result<T, Error>) -> Void
    ) {
        URLSession.shared.dataTask(with: request) { data, _, error in
            DispatchQueue.main.async {
                if let error = error {
                    return completion(.failure(error))
                }

                guard let data = data else {
                    return completion(.failure(NSError(domain: "No data", code: 500)))
                }

                let decoder = JSONDecoder()
                if dateDecoding {
                    decoder.dateDecodingStrategy = .custom { decoder in
                        let container = try decoder.singleValueContainer()
                        let string = try container.decode(String.self)

                        if let isoDate = ISO8601DateFormatter.iso.date(from: string) {
                            return isoDate
                        }

                        if let shortDate = DateFormatter.short.date(from: string) {
                            return shortDate
                        }

                        throw DecodingError.dataCorruptedError(in: container, debugDescription: "Bad date format: \(string)")
                    }
                }

                do {
                    let result = try decoder.decode(type, from: data)
                    completion(.success(result))
                } catch {
                    completion(.failure(error))
                }
            }
        }.resume()
    }

    func perform(_ request: URLRequest, completion: @escaping (Result<Void, Error>) -> Void) {
        URLSession.shared.dataTask(with: request) { _, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    return completion(.failure(error))
                }

                guard let statusCode = (response as? HTTPURLResponse)?.statusCode,
                      (200..<300).contains(statusCode) else {
                    return completion(.failure(NSError(domain: "Server error", code: 500)))
                }

                completion(.success(()))
            }
        }.resume()
    }
}

// MARK: - Date Helpers

extension DateFormatter {
    static var short: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }
}

private extension ISO8601DateFormatter {
    static var iso: ISO8601DateFormatter {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }
}
