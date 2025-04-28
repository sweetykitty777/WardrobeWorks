//  AuthView.swift
//  diploma

import SwiftUI

struct AuthView: View {
    @ObservedObject var viewModel: AuthViewModel
    @State private var showRegister = false

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Spacer()

                Text("Добро пожаловать")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                VStack(spacing: 16) {
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
                }
                .padding(.horizontal)

                if let error = viewModel.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }

                Button("Войти") {
                    viewModel.login()
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
                .padding(.horizontal)

                Button("Нет аккаунта? Зарегистрироваться") {
                    showRegister = true
                }
                .padding(.top, 12)

                Spacer()
            }
            .padding()
            .navigationBarHidden(true)
        }
        // MARK: — Регистрация
        .sheet(isPresented: $showRegister) {
            RegisterView(viewModel: RegisterViewModel())
        }
        // MARK: — Установка ника (появится, если needsUsername == true)
        .sheet(isPresented: $viewModel.needsUsername) {
            SetUsernameView()
                .environmentObject(viewModel)
        }
    }
}
