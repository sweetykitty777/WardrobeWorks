//
//  SetUsernameViewModel.swift
//  diploma
//
//  Created by Olga on 25.04.2025.
//

import Foundation
import Combine

class SetUsernameViewModel: ObservableObject {
    @Published var username: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var success: Bool = false

    private var cancellables = Set<AnyCancellable>()

    func setUsername() {
        let trimmed = username.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            errorMessage = "Никнейм не может быть пустым"
            return
        }

        guard let url = URL(string: "https://gate-acidnaya.amvera.io/api/v1/social-service/users/create") else {
            errorMessage = "Неверный URL"
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("*/*", forHTTPHeaderField: "Accept")

        let body = ["username": trimmed]
        do {
            request.httpBody = try JSONEncoder().encode(body)
        } catch {
            errorMessage = "Ошибка кодирования данных"
            return
        }

        isLoading = true
        errorMessage = nil

        URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { output in
                guard let resp = output.response as? HTTPURLResponse else {
                    throw URLError(.badServerResponse)
                }
                print("Status code:", resp.statusCode)
                if let str = String(data: output.data, encoding: .utf8) {
                    print("Body:", str)
                }
                guard (200...299).contains(resp.statusCode) else {
                    let msg = (try? JSONSerialization.jsonObject(with: output.data) as? [String:Any])?["message"] as? String
                    throw NSError(domain: msg ?? "Код \(resp.statusCode)", code: resp.statusCode)
                }
                return ()
            }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self = self else { return }
                self.isLoading = false
                if case let .failure(err) = completion {
                    self.errorMessage = "Не удалось установить ник: \(err.localizedDescription)"
                    print("Error:", err)
                }
            } receiveValue: { [weak self] in
                guard let self = self else { return }
                self.success = true
                print("Никнейм успешно установлен")
            }
            .store(in: &cancellables)
    }
}
