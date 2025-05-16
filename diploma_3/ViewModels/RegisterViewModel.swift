//
//  RegisterViewModel.swift
//  diploma
//
//  Created by Olga on 13.04.2025.
//

import Foundation
import Combine

class RegisterViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var confirmPassword: String = ""
    @Published var errorMessage: String?
    @Published var registrationSuccess: Bool = false

    private var cancellables = Set<AnyCancellable>()

    func register() {
        guard password == confirmPassword else {
            self.errorMessage = "Пароли не совпадают"
            return
        }

        guard let url = URL(string: "https://gateway-service-acidnaya.amvera.io/api/v1/auth/register") else {
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

        URLSession.shared.dataTaskPublisher(for: request)
            .map(\.data)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                if case let .failure(error) = completion {
                    self.errorMessage = "Ошибка регистрации: \(error.localizedDescription)"
                }
            }, receiveValue: { _ in
                self.registrationSuccess = true
                print("✅ Успешная регистрация")
            })
            .store(in: &cancellables)
    }
}
