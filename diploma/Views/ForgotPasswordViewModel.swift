//
//  ForgotPasswordViewModel.swift
//  diploma
//
//  Created by Olga on 11.05.2025.
//

import Foundation
import SwiftUI

class ForgotPasswordViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var errorMessage: String?
    @Published var isSending: Bool = false
    @Published var lastSentTime: Date?

    func sendResetEmail(completion: @escaping () -> Void) {
        errorMessage = nil

        guard isValidEmail(email) else {
            errorMessage = "Введите корректный email"
            return
        }

        if let last = lastSentTime, Date().timeIntervalSince(last) < 60 {
            errorMessage = "Отправлять можно не чаще, чем раз в минуту"
            return
        }

        isSending = true

        print("Отправляем email на восстановление: \(email)")

        AuthService.shared.sendForgotPassword(email: email) { [weak self] result in
            DispatchQueue.main.async {
                self?.isSending = false
                switch result {
                case .success:
                    print("Сервер подтвердил отправку инструкции на почту")
                    self?.lastSentTime = Date()
                    self?.errorMessage = "Инструкция отправлена на почту"
                    completion()
                case .failure(let error):
                    print("Ошибка при отправке: \(error.localizedDescription)")
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }


    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: email)
    }
}
