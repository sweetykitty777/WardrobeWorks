//
//  ForgotPasswordView.swift
//  diploma
//
//  Created by Olga on 11.05.2025.
//

import SwiftUI

struct ForgotPasswordView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel = ForgotPasswordViewModel()

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Введите ваш email")
                    .font(.headline)

                TextField("example@email.com", text: $viewModel.email)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(8)

                if let error = viewModel.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.footnote)
                        .multilineTextAlignment(.center)
                }

                Button(action: {
                    viewModel.sendResetEmail {
                        // можно закрыть, если отправка успешна
                        // dismiss()
                    }
                }) {
                    if viewModel.isSending {
                        ProgressView()
                    } else {
                        Text("Отправить")
                            .fontWeight(.semibold)
                    }
                }
                .disabled(viewModel.isSending)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)

                Spacer()
            }
            .padding()
            .navigationTitle("Забыли пароль?")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отмена") {
                        dismiss()
                    }
                }
            }
        }
    }
}
