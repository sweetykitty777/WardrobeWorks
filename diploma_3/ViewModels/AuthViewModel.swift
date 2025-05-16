import Foundation
import Combine

class AuthViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var isAuthenticated: Bool = false
    @Published var errorMessage: String?

    private var cancellables = Set<AnyCancellable>()

    func login() {
        guard let url = URL(string: "https://gate-acidnaya.amvera.io/api/v1/auth/login") else {
            self.errorMessage = "Неверный URL"
            return
        }

        let body = [
            "email": email,
            "password": password
        ]

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
        } catch {
            self.errorMessage = "Ошибка при создании запроса"
            return
        }

        print("URL: \(request.url?.absoluteString ?? "-")")
        print("Метод: \(request.httpMethod ?? "-")")
        print("Заголовки: \(request.allHTTPHeaderFields ?? [:])")
        if let body = request.httpBody, let bodyString = String(data: body, encoding: .utf8) {
            print("Тело запроса: \(bodyString)")
        }

        URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { output -> Data in
                if let httpResponse = output.response as? HTTPURLResponse {
                    if !(200...299).contains(httpResponse.statusCode) {
                        let raw = String(data: output.data, encoding: .utf8) ?? "нет данных"
                        print(" HTTP ошибка \(httpResponse.statusCode):\n\(raw)")
                        throw URLError(.userAuthenticationRequired)
                    }
                }
                return output.data
            }
            .decode(type: LoginResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                if case let .failure(error) = completion {
                    self.errorMessage = "Ошибка входа: \(error.localizedDescription)"
                }
            }, receiveValue: { response in
                print("Успешный вход. Токен: \(response.token)")
                KeychainHelper.save(response.token, forKey: "accessToken")
                self.isAuthenticated = true
                TokenManager.shared.startMonitoring(token: response.token)
            })
            .store(in: &cancellables)
    }


    func logout() {
        KeychainHelper.delete(forKey: "accessToken")
        self.isAuthenticated = false
        TokenManager.shared.stopMonitoring()
        print("Пользователь разлогинен")
    }
}
