//  AuthViewModel.swift
//  diploma

import Foundation
import Combine

class AuthViewModel: ObservableObject {
    // MARK: — Вход
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var isAuthenticated: Bool = false
    @Published var needsUsername: Bool = false
    @Published var errorMessage: String?

    private var cancellables = Set<AnyCancellable>()

    func login() {
        guard let url = URL(string: "https://gate-acidnaya.amvera.io/api/v1/auth/login") else {
            self.errorMessage = "Неверный URL для входа"
            return
        }

        let body = ["email": email, "password": password]
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
        } catch {
            self.errorMessage = "Ошибка кодирования данных для входа"
            return
        }

        URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { output in
                let status = (output.response as? HTTPURLResponse)?.statusCode ?? -1
                guard (200...299).contains(status) else {
                    let raw = String(data: output.data, encoding: .utf8) ?? "<no body>"
                    throw NSError(domain: "Login failed: \(status)\n\(raw)", code: status)
                }
                return output.data
            }
            .decode(type: LoginResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                if case let .failure(err) = completion {
                    self.errorMessage = "Ошибка входа: \(err.localizedDescription)"
                }
            }, receiveValue: { response in
                KeychainHelper.save(response.token, forKey: "accessToken")
                TokenManager.shared.startMonitoring(token: response.token)
                self.checkUsernameAfterLogin()
            })
            .store(in: &cancellables)
    }

    private func checkUsernameAfterLogin() {
        fetchCurrentUser { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let user):
                    self.needsUsername = user.username.trimmingCharacters(in: .whitespaces).isEmpty
                    if !self.needsUsername {
                        self.isAuthenticated = true
                    }
                case .failure:
                    self.needsUsername = true
                }
            }
        }
    }

    func setUsername(_ newUsername: String) {
        guard let url = URL(string: "https://gate-acidnaya.amvera.io/api/v1/social-service/users/create") else {
            self.errorMessage = "Неверный URL для ника"
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("*/*", forHTTPHeaderField: "Accept")

        if let token = KeychainHelper.get(forKey: "accessToken") {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else {
            self.errorMessage = "Нет токена авторизации"
            return
        }

        let payload = ["username": newUsername]
        do {
            request.httpBody = try JSONEncoder().encode(payload)
        } catch {
            self.errorMessage = "Ошибка кодирования ника"
            return
        }

        print("–– SET USERNAME REQUEST ––")
        print("URL:      \(request.url!.absoluteString)")
        print("Method:   \(request.httpMethod!)")
        print("Headers:  \(request.allHTTPHeaderFields!)")
        if let body = request.httpBody,
           let bodyString = String(data: body, encoding: .utf8) {
            print("Body:     \(bodyString)")
        }

        URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { output in
                let status = (output.response as? HTTPURLResponse)?.statusCode ?? -1
                print("🔁 setUsername response status: \(status)")
                if let rawBody = String(data: output.data, encoding: .utf8) {
                    print("📦 response body: \(rawBody)")
                }
                guard (200...299).contains(status) else {
                    throw NSError(domain: "Set username failed: \(status)", code: status)
                }
            }
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                if case let .failure(err) = completion {
                    self.errorMessage = "Не удалось сохранить ник: \(err.localizedDescription)"
                }
            }, receiveValue: {
                print("Ник сохранён успешно")
                self.needsUsername = false
                self.isAuthenticated = true
            })
            .store(in: &cancellables)
    }

    func logout() {
        KeychainHelper.delete(forKey: "accessToken")
        TokenManager.shared.stopMonitoring()
        isAuthenticated = false
        needsUsername = false
    }

    func fetchCurrentUser(completion: @escaping (Result<UserProfile, Error>) -> Void) {
        guard let url = URL(string: "https://gate-acidnaya.amvera.io/api/v1/social-service/users/self") else {
            completion(.success(UserProfile(id: 0, username: "", bio: nil, avatar: nil)))
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        if let token = KeychainHelper.get(forKey: "accessToken") {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if error != nil {
                    completion(.success(UserProfile(id: 0, username: "", bio: nil, avatar: nil)))
                    return
                }
                if let data = data,
                   let user = try? JSONDecoder().decode(UserProfile.self, from: data) {
                    completion(.success(user))
                } else {
                    completion(.success(UserProfile(id: 0, username: "", bio: nil, avatar: nil)))
                }
            }
        }.resume()
    }
}
