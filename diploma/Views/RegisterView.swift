import Foundation
import SwiftUI

struct RegisterView: View {
    @ObservedObject var viewModel: RegisterViewModel
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack(spacing: 20) {
            Spacer()

            Text("Создать аккаунт")
                .font(.largeTitle)
                .fontWeight(.bold)

            VStack(spacing: 16) {
                TextField("Никнейм", text: $viewModel.username)
                    .autocapitalization(.none)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(8)

                if !viewModel.isUsernameValid(viewModel.username) && !viewModel.username.isEmpty {
                    Text("Никнейм должен содержать только буквы и цифры, без пробелов и быть не короче 3 символов")
                        .font(.caption)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }

                TextField("Email", text: $viewModel.email)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(8)

                SecureField("Пароль", text: $viewModel.password)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(8)

                if !viewModel.isPasswordValid(viewModel.password) && !viewModel.password.isEmpty {
                    Text("Пароль должен быть длиннее 5 символов и содержать хотя бы одну заглавную букву")
                        .font(.caption)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }

                SecureField("Повторите пароль", text: $viewModel.confirmPassword)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(8)

                if viewModel.password != viewModel.confirmPassword && !viewModel.confirmPassword.isEmpty {
                    Text("Пароли не совпадают")
                        .font(.caption)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
            }
            .padding(.horizontal)

            if let error = viewModel.errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }

            Button("Зарегистрироваться") {
                viewModel.register()
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(viewModel.isFormValid ? Color.blue : Color.gray)
            .foregroundColor(.white)
            .cornerRadius(8)
            .padding(.horizontal)
            .disabled(!viewModel.isFormValid)

            Spacer()
        }
        .padding()
        .navigationBarHidden(true)
        .background(Color.white.edgesIgnoringSafeArea(.all))
        .onChange(of: viewModel.registrationSuccess) { success in
            if success {
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
}
