import Foundation
import Combine
import PostHog
import os

class RegisterViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var confirmPassword: String = ""
    @Published var username: String = ""
    @Published var errorMessage: String?
    @Published var registrationSuccess: Bool = false

    private var cancellables = Set<AnyCancellable>()
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "com.yourapp.identifier", category: "Register")

    var isFormValid: Bool {
        return isUsernameValid(username) &&
               isPasswordValid(password) &&
               isEmailValid(email) &&
               password == confirmPassword
    }

    func isUsernameValid(_ username: String) -> Bool {
        let regex = "^[A-Za-z0-9]{3,}$"
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: username)
    }

    func isPasswordValid(_ password: String) -> Bool {
        return password.count > 5 && password.rangeOfCharacter(from: .uppercaseLetters) != nil
    }

    func isEmailValid(_ email: String) -> Bool {
        let regex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: email)
    }

    func register() {
        guard isFormValid else {
            self.errorMessage = "Проверьте правильность заполнения всех полей"
            return
        }

        AuthService.shared.register(email: email, password: password, username: username) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }

                switch result {
                case .success:
                    self.registrationSuccess = true
                    self.errorMessage = nil

                    PostHogSDK.shared.capture("user signed up", properties: [
                        "email": self.email,
                        "username": self.username,
                        "method": "email"
                    ])

                    self.logger.info("Registration successful for \(self.email, privacy: .private)")

                case .failure(let error):
                    self.errorMessage = "Ошибка регистрации: \(error.localizedDescription)"

                    PostHogSDK.shared.capture("signup failed", properties: [
                        "email": self.email,
                        "error": error.localizedDescription
                    ])

                    self.logger.error("Registration failed for \(self.email, privacy: .private): \(error.localizedDescription, privacy: .public)")
                }
            }
        }
    }
}
