//  RegisterViewModel.swift
//  diploma

import Foundation
import Combine

class RegisterViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var confirmPassword: String = ""
    @Published var username: String = ""
    @Published var errorMessage: String?
    @Published var registrationSuccess: Bool = false

    private var cancellables = Set<AnyCancellable>()

    var isFormValid: Bool {
        return isUsernameValid(username) && isPasswordValid(password) && !email.isEmpty && password == confirmPassword
    }

    func isUsernameValid(_ username: String) -> Bool {
        let nicknameRegex = "^[A-Za-z0-9]{3,}$"
        let nicknamePredicate = NSPredicate(format: "SELF MATCHES %@", nicknameRegex)
        return nicknamePredicate.evaluate(with: username)
    }

    func isPasswordValid(_ password: String) -> Bool {
        return password.count > 5 && password.rangeOfCharacter(from: .uppercaseLetters) != nil
    }

    func register() {
        guard isFormValid else {
            self.errorMessage = "Проверьте правильность заполнения всех полей"
            return
        }

        guard let registerURL = URL(string: "https://gate-acidnaya.amvera.io/api/v1/auth/register") else {
            self.errorMessage = "Неверный URL для регистрации"
            return
        }

        let registerBody = [
            "email": email,
            "password": password,
            "username": username
        ]

        var registerRequest = URLRequest(url: registerURL)
        registerRequest.httpMethod = "POST"
        registerRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
       // registerRequest.addValue("*/*", forHTTPHeaderField: "Accept")

        do {
            registerRequest.httpBody = try JSONSerialization.data(
                withJSONObject: registerBody,
                options: []
            )
        } catch {
            self.errorMessage = "Ошибка при кодировании данных регистрации"
            return
        }

        URLSession.shared.dataTask(with: registerRequest) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.errorMessage = "Ошибка регистрации: \(error.localizedDescription)"
                    print("Registration network error:", error)
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse else {
                    self.errorMessage = "Неверный ответ сервера"
                    print("Invalid server response:", response ?? "nil")
                    return
                }

                let statusCode = httpResponse.statusCode
                print("Registration status code:", statusCode)

                if let data = data, let body = String(data: data, encoding: .utf8) {
                    print("Registration response body:", body)
                }

                if (200...299).contains(statusCode) {
                    self.registrationSuccess = true
                    print("Регистрация успешно завершена")
                } else {
                    var serverMessage = "Код ошибки: \(statusCode)"
                    if let data = data,
                       let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let msg = json["message"] as? String {
                        serverMessage = msg
                    }
                    self.errorMessage = "Ошибка регистрации: \(serverMessage)"
                    print("Server error during registration:", serverMessage)
                }
            }
        }.resume()
    }
}
