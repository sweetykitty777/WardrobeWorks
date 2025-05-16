import Foundation
import Combine
import os
import PostHog

class AuthViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var isAuthenticated: Bool = false
    @Published var errorMessage: String?

    private var cancellables = Set<AnyCancellable>()
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "com.yourapp.identifier", category: "Auth")

    func login() {
        AuthService.shared.login(email: email, password: password) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }

                switch result {
                case .success(let response):
                    KeychainHelper.save(response.token, forKey: "accessToken")
                    TokenManager.shared.startMonitoring(token: response.token)
                    self.isAuthenticated = true
                    self.errorMessage = nil

                    PostHogSDK.shared.identify(
                        self.email,
                        userProperties: [
                            "email": self.email
                        ]
                    )

                    PostHogSDK.shared.capture(
                        "user logged in",
                        properties: [
                            "method": "email",
                            "email": self.email
                        ]
                    )

                    self.logger.info("🔓 Login successful for \(self.email, privacy: .private)")

                case .failure(let error):
                    self.isAuthenticated = false
                    self.errorMessage = "Ошибка входа: \(error.localizedDescription)"

                    PostHogSDK.shared.capture(
                        "login failed",
                        properties: [
                            "email": self.email,
                            "error": error.localizedDescription
                        ]
                    )

                    self.logger.error("Login failed for \(self.email, privacy: .private): \(error.localizedDescription, privacy: .public)")
                }
            }
        }
    }
    
    func checkExistingToken() {
        if let token = KeychainHelper.get(forKey: "accessToken") {
            TokenManager.shared.startMonitoring(token: token)
            self.isAuthenticated = true

            // Можно добавить identify в PostHog, если хочешь:
            PostHogSDK.shared.capture("session resumed")
        } else {
            self.isAuthenticated = false
        }
    }


    func logout() {
        KeychainHelper.delete(forKey: "accessToken")
        TokenManager.shared.stopMonitoring()
        isAuthenticated = false

        PostHogSDK.shared.reset()

        PostHogSDK.shared.capture(
            "user logged out",
            properties: [
                "email": self.email
            ]
        )

        logger.info("User logged out: \(self.email, privacy: .private)")
    }
}
