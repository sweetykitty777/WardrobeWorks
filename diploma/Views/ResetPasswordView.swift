//
//  ResetPasswordView.swift
//  diploma
//
//  Created by Olga on 11.05.2025.
//
import SwiftUI

struct ResetPasswordView: View {
    let token: String
    var onSuccess: () -> Void

    @State private var newPassword = ""
    @State private var confirmPassword = ""
    @State private var message: String?

    var body: some View {
        VStack(spacing: 16) {
            SecureField("Новый пароль", text: $newPassword)
                .textContentType(.newPassword)
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(8)

            SecureField("Повторите пароль", text: $confirmPassword)
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(8)

            if let msg = message {
                Text(msg).foregroundColor(.gray).font(.footnote)
            }

            Button("Сохранить пароль") {
                submit()
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)

            Spacer()
        }
        .padding()
        .navigationTitle("Установка пароля")
    }

    func submit() {
        guard !newPassword.isEmpty else {
            message = "Введите новый пароль"
            return
        }
        guard newPassword == confirmPassword else {
            message = "Пароли не совпадают"
            return
        }

        AuthService.shared.resetPassword(token: token, newPassword: newPassword) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    message = "Пароль успешно обновлён"
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        onSuccess()
                    }
                case .failure(let error):
                    message = "Ошибка: \(error.localizedDescription)"
                }
            }
        }
    }
}
