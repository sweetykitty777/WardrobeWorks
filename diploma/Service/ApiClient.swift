import Foundation
import os

final class ApiClient {
    static let shared = ApiClient()
    private init() {}
    
    private let baseURL = "https://gate-acidnaya.amvera.io/api/v1"
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "com.yourapp.identifier", category: "ApiClient")
    
    func request<T: Decodable>(
        path: String,
        method: String,
        body: Data? = nil,
        headers: [String: String] = [:],
        decodeTo type: T.Type,
        dateDecoding: Bool = false,
        completion: @escaping (Result<T, Error>) -> Void
    ) {
        guard let url = URL(string: baseURL + path) else {
            let error = NSError(domain: "Invalid URL", code: 400)
            logger.error("Invalid URL: \(self.baseURL, privacy: .public)\(path, privacy: .public)")
            return completion(.failure(error))
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.httpBody = body
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let token = KeychainHelper.get(forKey: "accessToken") {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        headers.forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.logger.error("Network error: \(error.localizedDescription, privacy: .public)")
                    return completion(.failure(error))
                }
                
                if let httpResponse = response as? HTTPURLResponse {
                    self.logger.info("HTTP \(httpResponse.statusCode) for \(method, privacy: .public) \(path, privacy: .public)")
                }
                
                guard let data = data else {
                    self.logger.warning("No data received from \(path, privacy: .public)")
                    return completion(.failure(NSError(domain: "No data", code: 500)))
                }
                
                if let responseString = String(data: data, encoding: .utf8) {
                    self.logger.debug("Response body from \(path, privacy: .public):\n\(responseString, privacy: .public)")
                }
                
                if data.isEmpty || String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == true {
                    if let empty = EmptyResponse() as? T {
                        return completion(.success(empty))
                    }
                }
                
                let decoder = JSONDecoder()
                
                if dateDecoding {
                    let isoFormatter = ISO8601DateFormatter()
                    isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
                    
                    let shortFormatter = DateFormatter()
                    shortFormatter.locale = Locale(identifier: "en_US_POSIX")
                    shortFormatter.dateFormat = "yyyy-MM-dd"
                    
                    decoder.dateDecodingStrategy = .custom { decoder in
                        let container = try decoder.singleValueContainer()
                        let dateString = try container.decode(String.self)
                        
                        if let isoDate = isoFormatter.date(from: dateString) {
                            return isoDate
                        }
                        if let shortDate = shortFormatter.date(from: dateString) {
                            return shortDate
                        }
                        throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid date format: \(dateString)")
                    }
                }
                
                do {
                    let decoded = try decoder.decode(type, from: data)
                    self.logger.info("Successfully decoded response for \(path, privacy: .public)")
                    completion(.success(decoded))
                } catch {
                    self.logger.error("Decoding error for \(path, privacy: .public): \(String(describing: error), privacy: .public)")
                    completion(.failure(error))
                }
            }
        }.resume()
    }
    
    func requestVoid(
        path: String,
        method: String,
        body: Data? = nil,
        headers: [String: String] = [:],
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        request(path: path, method: method, body: body, headers: headers, decodeTo: EmptyResponse.self) { result in
            switch result {
            case .success:
                self.logger.info("Void request succeeded for \(path, privacy: .public)")
                completion(.success(()))
                
            case .failure(let error):
                if case DecodingError.dataCorrupted = error {
                    self.logger.info("Void request (non-JSON) succeeded for \(path, privacy: .public)")
                    completion(.success(()))
                } else {
                    self.logger.error("Void request failed for \(path, privacy: .public): \(String(describing: error), privacy: .public)")
                    completion(.failure(error))
                }
            }
        }
    }
    
    func unauthorizedRequestVoid(
        path: String,
        method: String,
        query: [String: String]? = nil,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        var fullPath = path

        if let query = query {
            let queryString = query.map { "\($0.key)=\($0.value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")" }
                                   .joined(separator: "&")
            fullPath += "?\(queryString)"
        }

        guard let url = URL(string: baseURL + fullPath) else {
            return completion(.failure(NSError(domain: "Invalid URL", code: 400)))
        }

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let httpResponse = response as? HTTPURLResponse {
                    self.logger.info("[UNAUTH] HTTP \(httpResponse.statusCode) for \(method) \(fullPath)")
                }

                if let error = error {
                    self.logger.error("[UNAUTH] Error: \(error.localizedDescription)")
                    return completion(.failure(error))
                }

                if let data = data, let responseString = String(data: data, encoding: .utf8) {
                    self.logger.debug("[UNAUTH] Response body:\n\(responseString)")
                }

                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode >= 400 {
                    return completion(.failure(NSError(domain: "HTTP error", code: httpResponse.statusCode)))
                }

                completion(.success(()))
            }
        }.resume()
    }
    
    func unauthorizedRequestVoid(
        path: String,
        method: String,
        query: [String: String]? = nil,
        body: Data? = nil,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        var fullPath = path

        if let query = query {
            let queryString = query.map {
                "\($0.key)=\($0.value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
            }.joined(separator: "&")
            fullPath += "?\(queryString)"
        }

        guard let url = URL(string: baseURL + fullPath) else {
            return completion(.failure(NSError(domain: "Invalid URL", code: 400)))
        }

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.httpBody = body
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let httpResponse = response as? HTTPURLResponse {
                    self.logger.info("[UNAUTH] HTTP \(httpResponse.statusCode) for \(method) \(fullPath)")
                }

                if let error = error {
                    self.logger.error(" [UNAUTH] Error: \(error.localizedDescription)")
                    return completion(.failure(error))
                }

                if let data = data, let responseString = String(data: data, encoding: .utf8) {
                    self.logger.debug("[UNAUTH] Response body:\n\(responseString)")
                }

                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode >= 400 {
                    return completion(.failure(NSError(domain: "HTTP error", code: httpResponse.statusCode)))
                }

                completion(.success(()))
            }
        }.resume()
    }

    
}


private struct EmptyResponse: Decodable {
    init(from decoder: Decoder) throws {
        if let container = try? decoder.singleValueContainer() {
            _ = try? container.decode(String.self)
        }
    }
    init() {}
}


