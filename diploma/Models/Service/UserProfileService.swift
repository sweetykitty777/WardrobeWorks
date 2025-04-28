// MARK: - UserProfileService.swift

import Foundation

class UserProfileService {
    static let shared = UserProfileService()

    func fetchProfile(completion: @escaping (Result<UserProfile, Error>) -> Void) {
        guard let url = URL(string: "https://gate-acidnaya.amvera.io/api/v1/social-service/users/self") else {
            completion(.failure(NSError(domain: "Invalid URL", code: 400)))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        if let token = KeychainHelper.get(forKey: "accessToken") {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        URLSession.shared.dataTask(with: request) { data, _, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                    return
                }

                guard let data = data else {
                    completion(.failure(NSError(domain: "No data", code: 500)))
                    return
                }

                do {
                    let profile = try JSONDecoder().decode(UserProfile.self, from: data)
                    completion(.success(profile))
                } catch {
                    completion(.failure(error))
                }
            }
        }.resume()
    }

    func updateBio(_ bio: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let url = URL(string: "https://gate-acidnaya.amvera.io/api/v1/social-service/users/bio/update") else {
            completion(.failure(NSError(domain: "Invalid URL", code: 400)))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let token = KeychainHelper.get(forKey: "accessToken") {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        let body = ["bio": bio]
        request.httpBody = try? JSONEncoder().encode(body)

        URLSession.shared.dataTask(with: request) { _, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse, (200..<300).contains(httpResponse.statusCode) else {
                    completion(.failure(NSError(domain: "Server error", code: 500)))
                    return
                }

                completion(.success(()))
            }
        }.resume()
    }

    func updateAvatar(_ avatarUrl: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let url = URL(string: "https://gate-acidnaya.amvera.io/api/v1/social-service/users/avatar/update") else {
            completion(.failure(NSError(domain: "Invalid URL", code: 400)))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let token = KeychainHelper.get(forKey: "accessToken") {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        let body = ["avatar": avatarUrl]
        request.httpBody = try? JSONEncoder().encode(body)

        URLSession.shared.dataTask(with: request) { _, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse, (200..<300).contains(httpResponse.statusCode) else {
                    completion(.failure(NSError(domain: "Server error", code: 500)))
                    return
                }

                completion(.success(()))
            }
        }.resume()
    }
    func fetchCurrentUser(completion: @escaping (Result<UserProfile, Error>) -> Void) {
            guard let url = URL(string: "https://gate-acidnaya.amvera.io/api/v1/social-service/users/self") else {
                completion(.failure(NSError(domain: "Invalid URL", code: 400)))
                return
            }

            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            if let token = KeychainHelper.get(forKey: "accessToken") {
                request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
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
                    let user = try JSONDecoder().decode(UserProfile.self, from: data)
                    completion(.success(user))
                } catch {
                    completion(.failure(error))
                }
            }.resume()
        }
    
    func fetchUserById(_ userId: Int, completion: @escaping (Result<UserProfile, Error>) -> Void) {
        guard let url = URL(string: "https://gate-acidnaya.amvera.io/api/v1/social-service/users/\(userId)") else {
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
                    completion(.failure(error))
                    return
                }

                guard let data = data else {
                    completion(.failure(NSError(domain: "No data", code: 500)))
                    return
                }

                do {
                    let user = try JSONDecoder().decode(UserProfile.self, from: data)
                    completion(.success(user))
                } catch {
                    print("Ошибка декодирования пользователя по id: \(error)")
                    completion(.failure(error))
                }
            }
        }.resume()
    }
    
    

    
}
